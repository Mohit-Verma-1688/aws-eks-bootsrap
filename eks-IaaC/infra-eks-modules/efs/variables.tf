variable "env" {
  description = "Environment name."
  type        = string
}

variable "efs_name" {
  description = "EFS  name."
  type        = string
}


variable "vpc_cidr_block" {
  type = string
}


variable "private_sub" {
  description = "CIDR ranges for private subnets."
  type        = list(string)
}

variable "enable_efs" {
  type = string
}

variable "vpc_id"{
  type = string
}
