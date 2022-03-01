#######################################
# Global Tags
#######################################
environment = "Dev"
client_name = "assessment"
creator     = "Fawzi H"
departement = "X"
compliance  = "HIPAA"


#######################################
# VPC CIDR Range
#######################################
vpc_cidr = "192.168.0.0/16"

#######################################
# ALB, TargetGroup & Listener Variables
#######################################
alb_termination       = false
tg_port               = "80"
tg_protocol           = "HTTP"
health_check_interval = "10"
health_check_path     = "/"
health_check_matcher  = "200"
health_check_timeout  = "5"
listener_port         = "80"
listener_protocol     = "HTTP"
health_check_port     = "80"
health_check_protocol = "HTTP"

#######################################
# Autoscaling Variables
#######################################

asg_max_size         = "6"
asg_min_size         = "3"
asg_desired_capacity = "3"