variable "name_prefix" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "cluster_oidc_provider_arn" {
  type = string
}

variable "namespace" {
  type = string
}

variable "service_account_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
