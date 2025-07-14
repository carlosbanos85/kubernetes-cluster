locals {
  master_hostname = "${var.project_name}-master"

  # Define Cilium configuration variables
  cilium_config = {
    cluster_name               = var.project_name
    master_ip                  = var.master_hostname # This will be the internal hostname
    master_private_ip          = ""                  # Will be populated after instance creation
    ingress_controller_enabled = var.enable_ingress_controller
    lb_ip_pool                 = var.cilium_lb_ip_pool
  }
}
