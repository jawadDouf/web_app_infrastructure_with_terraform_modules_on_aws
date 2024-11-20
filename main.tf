provider "aws" {
  region = "us-east-1"
}

# Import the vpc module
module "vpc" {
  # specify the module's source
  source = "./modules/vpc"
  
  # initialize the variables
  environment = "dev"
  # specify the allowed ip-adresses inside the vpc and subnets
  cidr_block = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.0.0/24"]
  private_subnet_cidrs = ["10.0.0.0/24"]
  # specify the availablity zones
  public_availability_zones = ["us-east-1a"]
  private_availability_zones = ["us-east-1b"]  
}

module "security_group" {
  source = "./modules/security_group"
  environment = "dev"
  # get the vpc id from the module's output
  vpc_id = module.vpc.vpc_id


}

module "ecs" {
  source = "./modules/ecs"
  # naming of the launch template
  aws_launch_template_name_prefix = "ec2-launch-template"

 # specify the security group id
 security_group_ids = module.security_group.security_group_id

 # Specify the subnets ids
 subnet_ids = concat(module.vpc.public_subnet_ids , module.vpc.private_subnet_ids) 
 
 # Set the initial number of ec2s
 asg_desired_capacity = 5
 asg_max_size = 10
 asg_min_size = 4

 # define the container that will be deployed in the created ecs
 container_name = "example_container"
 container_image = "nginx:1-alpine-perl"


}