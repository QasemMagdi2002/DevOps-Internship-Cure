output "regional_certificate_arn" {
  description = "ACM certificate ARN for regional ALB."
  value       = aws_acm_certificate_validation.regional.certificate_arn
}

output "cloudfront_certificate_arn" {
  description = "ACM certificate ARN for CloudFront in us-east-1."
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}
