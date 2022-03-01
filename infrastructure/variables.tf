#######################################
# Tags Variables
#######################################
variable "environment" {
  type        = string
  description = "Environment Name"
}

variable "client_name" {
  type        = string
  description = "Client Name."
}

variable "creator" {
  type        = string
  description = "The name of the Infrastructure creator"
}

variable "departement" {
  description = "Departement NAme"
}

variable "compliance" {
  description = "Compliance Name eg. HIPAA PCIDSS etc"
}


variable "vpc_cidr" {}





#######################################
# Security Group Variables
#######################################
// Vars should be not be changed for the SG
variable "sg_alb_ingress_port" {
  description = "Ingress Port Number to ALB"
  type        = number
  default     = 80
}
variable "sg_alb_ingress_protocol" {
  description = "Ingress Protocol to ALB"
  type        = string
  default     = "tcp"
}

variable "sg_web_ingress_port" {
  description = "Ingress Port Number to the webservers"
  type        = number
  default     = 80
}
variable "sg_web_ingress_protocol" {
  description = "Ingress protocol to the webservers"
  type        = string
  default     = "tcp"
}

#######################################
# ALB, TargetGroup & Listener Variables
#######################################
variable "alb_termination" {
  description = "ALB Deletion Protection"
  type        = bool
}

variable "tg_port" {
  description = "Target Group Port"
  type        = string
}

variable "tg_protocol" {
  description = "Target Group Protocol"
  type        = string
}

variable "health_check_interval" {
  description = "Amount of time, in seconds, between health checks"
  type        = string
}

variable "health_check_path" {
  description = "Webserver Health Check Path"
  type        = string
}

variable "health_check_matcher" {
  description = "Health Check Response Code"
  type        = string
}

variable "health_check_timeout" {
  description = "Seconds, during which no response means a failed health check"
  type        = string
}

variable "health_check_port" {}

variable "health_check_protocol" {}

variable "listener_port" {
  description = "ALB Listening Port"
  type        = number
}

variable "listener_protocol" {
  description = "ALB Listening Protocol"
  type        = string
}

#######################################
# Autoscaling Variables
#######################################

variable "asg_max_size" {
  description = "Autoscaling Mazimum Size"
  type        = string

}

variable "asg_min_size" {
  description = "Autoscaling Mazimum Size"
  type        = string
}


variable "asg_desired_capacity" {
  description = "Autoscaling Desired Size"
}


/*
variable "max_size" {
  default = 6
}

variable "min_size" {
  default = 3
}
*/