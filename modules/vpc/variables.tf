variable "environment" {
  type = string
  description = "Env name"
}

variable "cidr_block" {
  type = string
  default = ""
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

variable "private_availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}
