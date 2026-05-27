variable "root_zone_id" {
  description = "Route53 hosted zone ID."
  type        = string
}

variable "frontend_domain" {
  description = "CloudFront public frontend domain."
  type        = string
}

variable "frontend_origin_domain" {
  description = "ALB origin frontend domain."
  type        = string
}

variable "acm_certificate_arn" {
  description = "CloudFront ACM certificate ARN."
  type        = string
}

variable "common_tags" {
  description = "Common tags."
  type        = map(string)
}
