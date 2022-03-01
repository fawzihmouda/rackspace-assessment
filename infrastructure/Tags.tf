#######################################
# Global Tags
#######################################

// Example Of Common tags to be assigned to all resources
locals {

  global_tags = {
    client_name = var.client_name
    environment = var.environment
    createdby   = var.creator
    departement = var.departement
    compliance  = var.compliance
  }
}