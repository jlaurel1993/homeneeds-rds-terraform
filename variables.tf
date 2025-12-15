variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "homeneeds"
}

variable "db_username" {
  description = "Master/initial admin username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master/initial admin password (DO NOT COMMIT)"
  type        = string
  sensitive   = true
}

variable "public_access" {
  description = "Allow public connections (dev only!)"
  type        = bool
  default     = true
}

variable "allow_cidr" {
  description = "CIDR allowed for MySQL ingress (fallback if IP lookup fails)"
  type        = string
  default     = "0.0.0.0/0"
}
