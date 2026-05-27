output "service_account_name" {
  value = local.service_account_name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}
