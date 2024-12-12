# launch template
variable "security_group_ids" {
  type = list(string)
  description = "an array of security groups ids"
}

variable "aws_launch_template_name_prefix" {
  type = string
  default = "ec2-template"
}

variable "aws_launch_template_tags" {
  type = string
  default = "ecs-instance"
}
# vpc config variables
variable "vpc_id" {
  type = string
}
# auto-scaling group variables
variable "subnet_ids" {
  type = list(string)
  description = "an array of subnet ids"
}

variable "asg_max_size" {
  type = number
}

variable "asg_min_size" {
  type = number
}

variable "asg_desired_capacity" {
  type = number
}

# ecs cluster variables
variable "ecs_cluster_name" {
  type = string
  default = "my-ecs-cluster"
}

# ecs capacity providers
variable "aws_ecs_capacity_provider_name" {
    type = string
    default = "test1"
}

# container to be deployed variables
variable "container_name" {
  type = string
  description = "-----"
}

variable "container_image" {
  type = string
  description = "--------"
}

# ecs service variables
variable "ecs_service_name" {
  default = "my-ecs-service"
  type = string
}

variable "container_port" {
  type = number
  default = 80
}

variable "container_cpu" {
  type = number
  default = 256
}

variable "container_memory" {
  type = number
  default = 512
}

