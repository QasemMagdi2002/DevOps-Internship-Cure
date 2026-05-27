variable "root_zone_id" {
  description = "Route53 public hosted zone ID."
  type        = string
}

variable "frontend_domain" {
  description = "CloudFront frontend domain."
  type        = string
}

variable "frontend_origin_domain" {
  description = "ALB frontend origin domain."
  type        = string
}

variable "backend_domain" {
  description = "Backend API domain."
  type        = string
}

variable "common_tags" {
  description = "Common tags."
  type        = map(string)
}
