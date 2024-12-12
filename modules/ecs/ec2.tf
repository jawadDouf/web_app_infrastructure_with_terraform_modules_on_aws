# Create an IAM Role for ECS instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecsInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonEC2ContainerServiceForEC2Role policy
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Create an Instance Profile for the IAM Role
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceRole"
  role = aws_iam_role.ecs_instance_role.name
}


#to get a specific ami of the ec2 launch template
data "aws_ami" "ec2_ami" {

        most_recent = true                     # Fetch the most recent AMI
        owners      = ["099720109477"]         # Canonical (official Ubuntu owner)

        # to filter available amis based on name
          filter {
                name   = "name"
                values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
             }
}

# Define the ec2 instances launch template
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = var.aws_launch_template_name_prefix
  image_id      = data.aws_ami.ec2_ami.id # the id of the os used
  instance_type = "t3.micro"

  key_name               = "ec2ecsglog"
  vpc_security_group_ids =  var.security_group_ids #the security group that will be allocated to the ec2 insrances
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.aws_launch_template_tags
    }
  }

  user_data = filebase64("${path.module}/ecs.sh") # execute a script that sets up an env variable in the ec2 instances
}

# Define auto-scale group that will creats ec2 instances will be used by ecs
resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = var.subnet_ids # specify in which subnets the asg will create the ec2 instances
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  } # => specify the launch_template


  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}