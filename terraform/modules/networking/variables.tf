variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 10))
    error_message = "vpc_cidr must be valid."
  }
}

variable "enable_nat_gateway" {
  type = bool
}

variable "common_tags" {
  type = map(string)
}
