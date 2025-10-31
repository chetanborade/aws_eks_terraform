data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "${var.cluster_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.cluster_name}-cluster-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.cluster_name}-cluster-sg" }
  )
}

resource "aws_security_group" "eks_node_group_sg" {
  name_prefix = "${var.cluster_name}-node-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.cluster_name}-node-sg" }
  )
}

resource "aws_eks_cluster" "this" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.eks_cluster_role.arn
  version                       = var.cluster_version
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = var.common_tags
}

# ============================================================================
# MANUAL WORKER NODES CONFIGURATION (COMMENTED OUT - REPLACED WITH MANAGED)
# ============================================================================

# # Get the latest EKS optimized AMI
# data "aws_ami" "eks_worker" {
#   filter {
#     name   = "name"
#     values = ["amazon-eks-node-${var.cluster_version}-v*"]
#   }
#   most_recent = true
#   owners      = ["602401143452"] # Amazon EKS AMI Account ID
# }

# # Create instance profile for worker nodes
# resource "aws_iam_instance_profile" "eks_worker_node_instance_profile" {
#   name = "${var.cluster_name}-worker-node-instance-profile"
#   role = aws_iam_role.eks_node_group_role.name
# }

# # User data script for worker node registration
# locals {
#   userdata = base64encode(<<-USERDATA
#     #!/bin/bash
#     set -o xtrace
#     /etc/eks/bootstrap.sh ${aws_eks_cluster.this.name}
#     USERDATA
#   )
# }

# # Launch template for worker nodes
# resource "aws_launch_template" "eks_worker" {
#   name_prefix   = "${var.cluster_name}-worker-"
#   image_id      = data.aws_ami.eks_worker.id
#   instance_type = var.manual_node_config.instance_type
#   key_name      = var.manual_node_config.key_name

#   vpc_security_group_ids = [aws_security_group.eks_node_group_sg.id]

#   iam_instance_profile {
#     name = aws_iam_instance_profile.eks_worker_node_instance_profile.name
#   }

#   user_data = local.userdata

#   block_device_mappings {
#     device_name = "/dev/xvda"
#     ebs {
#       volume_size = var.manual_node_config.disk_size
#       volume_type = "gp3"
#       encrypted   = true
#     }
#   }

#   tag_specifications {
#     resource_type = "instance"
#     tags = merge(
#       var.common_tags,
#       {
#         Name                                        = "${var.cluster_name}-worker"
#         "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#       }
#     )
#   }

#   tags = var.common_tags
# }

# # Auto Scaling Group for worker nodes
# resource "aws_autoscaling_group" "eks_worker" {
#   name                = "${var.cluster_name}-worker-asg"
#   vpc_zone_identifier = var.private_subnet_ids
#   target_group_arns   = []
#   health_check_type   = "EC2"
  
#   min_size         = var.manual_node_config.min_size
#   max_size         = var.manual_node_config.max_size
#   desired_capacity = var.manual_node_config.desired_size

#   launch_template {
#     id      = aws_launch_template.eks_worker.id
#     version = "$Latest"
#   }

#   tag {
#     key                 = "Name"
#     value               = "${var.cluster_name}-worker-asg"
#     propagate_at_launch = false
#   }

#   tag {
#     key                 = "kubernetes.io/cluster/${var.cluster_name}"
#     value               = "owned"
#     propagate_at_launch = true
#   }

#   # Ensure proper lifecycle
#   instance_refresh {
#     strategy = "Rolling"
#     preferences {
#       min_healthy_percentage = 50
#     }
#   }
# }

# ============================================================================
# AWS MANAGED NODE GROUP CONFIGURATION
# ============================================================================

resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-managed-nodes"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = var.managed_node_config.capacity_type
  instance_types = var.managed_node_config.instance_types

  scaling_config {
    desired_size = var.managed_node_config.scaling_config.desired_size
    max_size     = var.managed_node_config.scaling_config.max_size
    min_size     = var.managed_node_config.scaling_config.min_size
  }

  update_config {
    max_unavailable = var.managed_node_config.max_unavailable
  }

  # Optional: Remote access configuration
  remote_access {
    ec2_ssh_key = var.managed_node_config.key_name
    source_security_group_ids = [aws_security_group.eks_node_group_sg.id]
  }

  # Disk configuration
  disk_size = var.managed_node_config.disk_size

  # AMI type for EKS optimized AMIs
  ami_type = var.managed_node_config.ami_type

  # Launch template for additional customization (optional)
  # launch_template {
  #   name    = aws_launch_template.managed_nodes.name
  #   version = aws_launch_template.managed_nodes.latest_version
  # }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.cluster_name}-managed-nodes"
    }
  )

  # Lifecycle configuration
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}