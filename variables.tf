variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "gameserver-monitoring"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "github_repo" {
  description = "GitHub repo in the format 'owner/repo-name' (used for OIDC trust)"
  type        = string
  # Example: "myusername/gameserver-monitoring"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "gameserver-monitoring"
    ManagedBy   = "terraform"
  }
}
