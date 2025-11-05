variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS SSO profile name"
  type        = string
  default     = "sso"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "november-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}
