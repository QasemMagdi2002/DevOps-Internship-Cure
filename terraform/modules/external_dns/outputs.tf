output "role_arn" {
  description = "ExternalDNS IRSA role ARN."
  value       = aws_iam_role.this.arn
}
