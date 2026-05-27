output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Private S3 bucket for medical documents."
  value       = module.s3.bucket_name
}

output "rds_endpoint" {
  description = "RDS endpoint."
  value       = module.rds.db_endpoint
}

output "db_name" {
  description = "Database name."
  value       = var.db_name
}

output "db_username" {
  description = "Database username."
  value       = var.db_username
}

output "backend_irsa_role_arn" {
  description = "IAM role ARN for backend ServiceAccount."
  value       = module.irsa.role_arn
}

output "jwt_secret_note" {
  description = "JWT secret handling note."
  value       = "JWT_SECRET is not managed by Terraform. Create it manually in the Kubernetes Secret or manage it through a secrets manager."
}

output "kubectl_update_kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "frontend_domain" {
  description = "Frontend custom domain."
  value       = var.frontend_domain
}

output "frontend_origin_domain" {
  description = "Frontend ALB origin domain."
  value       = var.frontend_origin_domain
}

output "backend_domain" {
  description = "Backend API custom domain."
  value       = var.backend_domain
}

output "regional_acm_certificate_arn" {
  description = "Regional ACM certificate ARN for ALB."
  value       = module.acm.regional_certificate_arn
}

output "cloudfront_certificate_arn" {
  description = "CloudFront ACM certificate ARN."
  value       = module.acm.cloudfront_certificate_arn
}

output "cloudfront_domain_name" {
  description = "CloudFront default domain name."
  value       = module.cloudfront.cloudfront_domain_name
}

output "external_dns_role_arn" {
  description = "ExternalDNS IAM role ARN."
  value       = module.external_dns.role_arn
}
