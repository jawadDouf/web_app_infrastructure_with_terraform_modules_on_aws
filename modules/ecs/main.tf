# ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name ## naming the ecs cluster
}

# define the ecs provider
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = var.aws_ecs_capacity_provider_name 

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn # specify the auto-scaling group will be used

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}

# link the ecs cluster to the provider
resource "aws_ecs_cluster_capacity_providers" "example" {
  # link the esg with the ecs
  cluster_name = aws_ecs_cluster.ecs_cluster.name 

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name] 

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

# define the ecs cluster task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family             = "my-ecs-task"
  network_mode       = "awsvpc"
  execution_role_arn = "arn:aws:iam::532199187081:role/ecsTaskExecutionRole"
  cpu                = 256 
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  # define the containers will be used in the ecs
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}


# define the ecs service 
resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id # specify the ecs cluster 
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn # specify the task will be handled by the ecs
  desired_count   = 2

  network_configuration {
    subnets         = var.subnet_ids 
    security_groups = var.security_group_ids 
  }

  force_new_deployment = true
  
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}
