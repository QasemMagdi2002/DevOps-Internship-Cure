variable "name_prefix" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_master_password" {
  type      = string
  sensitive = true
  ephemeral = true
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "multi_az" {
  type = bool
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for RDS subnet group."
  }
}

variable "eks_node_sg_id" {
  type = string
}

variable "protect_data_resources" {
  type = bool
}

variable "common_tags" {
  type = map(string)
}
