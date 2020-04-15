variable "prefix" {
  description = "The common prefix for names."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The VPC network."
  type        = string
  default     = "10.0.0.0/24"
}

variable "max_number_of_subnets" {
  description = "The maximum number of subnets."
  type        = number
  default     = 8

  #  validation {
  #    condition = var.max_number_of_subnets >= var.public_subnet_count + var.private_subnet_count
  #    error_message = "The max_number_of_subnets is not sufficient"
  #  }
}

variable "number_of_public_subnets" {
  description = "The number of public subnets."
  type        = number
  default     = 2
}

variable "number_of_private_subnets" {
  description = "The number of private subnets."
  type        = number
  default     = 2
}

variable "enable_nat" {
  description = "Determines whetehr NAT gateways ought to be provided for private subnets"
  type        = bool
  default     = true
}
