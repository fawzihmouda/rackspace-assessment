#################################################
# Application Load Balancer
#################################################

resource "aws_lb" "alb" {
  name                             = "web-alb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.sg_alb.id]
  subnets                          = aws_subnet.alb_subnet.*.id
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = var.alb_termination
  tags = {
    Name = "public-lb${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  }
}

// ALB Listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_target_group.arn
  }
}

#################################################
# Target Group
#################################################
resource "aws_lb_target_group" "asg_target_group" {
  target_type                   = "instance"
  name                          = "tg-webservers"
  port                          = var.tg_port
  protocol                      = var.tg_protocol
  vpc_id                        = aws_vpc.vpc.id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    enabled = true

    interval = var.health_check_interval
    path     = var.health_check_path
    matcher  = var.health_check_matcher
    timeout  = var.health_check_timeout
    port     = var.health_check_port
    protocol = var.health_check_protocol
  }

  tags = {
    Name = "tg-webservers${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  }

}





