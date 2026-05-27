variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "cure"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must be lowercase, 3-21 chars, and contain only letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment must be one of: development, staging, production."
  }
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must look like eu-central-1, me-south-1, or us-east-1."
  }
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "qasem"

  validation {
    condition     = length(var.owner) >= 2
    error_message = "owner must not be empty."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.40.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 10))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet egress. Disable for lower-cost demos only."
  type        = bool
  default     = true
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^1\\.(29|30|31|32)$", var.eks_cluster_version))
    error_message = "eks_cluster_version must be a supported 1.29+ version."
  }
}

variable "node_instance_types" {
  description = "EKS managed node group instance types."
  type        = list(string)
  default     = ["t3.small"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "At least one node instance type is required."
  }
}

variable "node_desired_size" {
  description = "Desired EKS node count."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= 1 && var.node_desired_size <= 5
    error_message = "node_desired_size must be between 1 and 5."
  }
}

variable "node_min_size" {
  description = "Minimum EKS node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum EKS node count."
  type        = number
  default     = 5
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.", var.rds_instance_class))
    error_message = "rds_instance_class must start with db."
  }
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.rds_allocated_storage >= 20
    error_message = "RDS allocated storage must be at least 20 GB."
  }
}

variable "rds_multi_az" {
  description = "Enable RDS Multi-AZ. True is production-grade but more expensive."
  type        = bool
  default     = false
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "cure_db"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{2,30}$", var.db_name))
    error_message = "db_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "cure_app"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{2,30}$", var.db_username))
    error_message = "db_username must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_master_password" {
  description = "Ephemeral RDS master password. Pass during terraform apply."
  type        = string
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = length(var.db_master_password) >= 16
    error_message = "db_master_password must be at least 16 characters."
  }
}

variable "root_domain_name" {
  description = "Root domain managed by Route53."
  type        = string
  default     = "qasemcuredevops.xyz"

  validation {
    condition     = can(regex("^[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.root_domain_name))
    error_message = "root_domain_name must be a valid domain like qasemcuredevops.xyz."
  }
}

variable "frontend_domain" {
  description = "Public frontend domain served through CloudFront."
  type        = string
  default     = "app.qasemcuredevops.xyz"

  validation {
    condition     = can(regex("^app\\.", var.frontend_domain))
    error_message = "frontend_domain should start with app."
  }
}

variable "frontend_origin_domain" {
  description = "Origin domain routed by ALB to the frontend service."
  type        = string
  default     = "origin-app.qasemcuredevops.xyz"

  validation {
    condition     = can(regex("^origin-app\\.", var.frontend_origin_domain))
    error_message = "frontend_origin_domain should start with origin-app."
  }
}

variable "backend_domain" {
  description = "Public backend API domain routed by ALB."
  type        = string
  default     = "api.qasemcuredevops.xyz"

  validation {
    condition     = can(regex("^api\\.", var.backend_domain))
    error_message = "backend_domain should start with api."
  }
}

variable "enable_monitoring" {
  description = "Install kube-prometheus-stack."
  type        = bool
  default     = true
}

variable "protect_data_resources" {
  description = "Enable prevent_destroy for data resources like S3 and RDS."
  type        = bool
  default     = false
}
