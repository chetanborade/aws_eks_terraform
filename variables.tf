variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "eks-prod-vpc"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

# Manual node configuration (commented out - keeping for reference)
# variable "manual_node_config" {
#   description = "Configuration for manual EKS worker nodes"
#   type = object({
#     instance_type  = string
#     key_name       = string
#     disk_size      = number
#     desired_size   = number
#     max_size       = number
#     min_size       = number
#   })
#   default = {
#     instance_type  = "t3.medium"
#     key_name       = "my-key-pair"
#     disk_size      = 20
#     desired_size   = 2
#     max_size       = 4
#     min_size       = 1
#   }
# }

variable "managed_node_config" {
  description = "Configuration for AWS managed EKS node group"
  type = object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    disk_size        = number
    ami_type         = string
    key_name         = string
    max_unavailable  = number
  })
  default = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    scaling_config = {
      desired_size = 2
      max_size     = 4
      min_size     = 1
    }
    disk_size       = 20
    ami_type        = "AL2_x86_64"  # Amazon Linux 2 EKS optimized AMI
    key_name        = "my-key-pair"  # For SSH access
    max_unavailable = 1
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "eks-cluster"
    Owner       = "terraform"
  }
}
