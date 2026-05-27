variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_oidc_issuer_url" {
  type = string
}

variable "cluster_oidc_provider_arn" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "root_domain_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}
