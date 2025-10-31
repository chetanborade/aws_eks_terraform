variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster will be created"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs where the worker nodes will be placed"
  type        = list(string)
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
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}