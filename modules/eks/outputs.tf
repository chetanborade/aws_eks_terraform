output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.this.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

# Manual worker node outputs (commented out)
# output "worker_asg_name" {
#   description = "Name of the worker nodes Auto Scaling Group"
#   value       = aws_autoscaling_group.eks_worker.name
# }

# output "worker_launch_template_id" {
#   description = "ID of the worker nodes launch template"
#   value       = aws_launch_template.eks_worker.id
# }

# Managed node group outputs
output "managed_node_group_arn" {
  description = "ARN of the managed node group"
  value       = aws_eks_node_group.managed_nodes.arn
}

output "managed_node_group_status" {
  description = "Status of the managed node group"
  value       = aws_eks_node_group.managed_nodes.status
}

output "managed_node_group_capacity_type" {
  description = "Capacity type of the managed node group"
  value       = aws_eks_node_group.managed_nodes.capacity_type
}

output "managed_node_group_instance_types" {
  description = "Instance types of the managed node group"
  value       = aws_eks_node_group.managed_nodes.instance_types
}