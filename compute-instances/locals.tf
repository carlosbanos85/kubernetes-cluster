locals {
  master_hostname = "${var.project_name}-master"

  # Gateway API configuration
  gateway_config = {
    cluster_name    = var.project_name
    master_ip       = var.master_hostname
    gateway_enabled = true
    hubble_enabled  = true
  }

}
