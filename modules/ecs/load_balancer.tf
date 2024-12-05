# initialize an alb
resource "aws_lb" "ecs_lb" {
  name               = "ecs-service-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

#
resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-target-group"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}


