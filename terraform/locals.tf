locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Assessment  = "cure-cloud-devops"
  }

  backend_namespace = "cure"

  backend_cors_origins = "https://${var.frontend_domain}"
}
