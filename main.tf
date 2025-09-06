# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Get the latest Ubuntu 22.04 LTS image for ARM64
data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Network Module
module "network" {
  source = "./network"

  compartment_id     = var.compartment_id
  project_name       = var.project_name
  environment        = var.environment
  vcn_cidr           = var.vcn_cidr
  master_subnet_cidr = var.master_subnet_cidr
  worker_subnet_cidr = var.worker_subnet_cidr
  lb_subnet_cidr     = var.lb_subnet_cidr
  common_tags        = local.common_tags
}

# Compute Instances Module
module "compute_instances" {
  source = "./compute-instances"

  # Dependencies
  depends_on = [module.network]

  # Pass variables to compute module
  compartment_id      = var.compartment_id
  project_name        = var.project_name
  environment         = var.environment
  availability_domain = local.availability_domain
  instance_image_id   = local.instance_image
  instance_shape      = var.instance_shape
  instance_ocpus      = var.instance_ocpus
  instance_memory_gb  = var.instance_memory_gb
  boot_volume_size_gb = var.boot_volume_size_gb
  worker_count        = var.worker_count
  ssh_public_key      = var.ssh_public_key
  cluster_domain      = var.cluster_domain
  master_hostname     = var.master_hostname
  worker_hostname     = var.worker_hostname
  cilium_version      = var.cilium_version
  vcn_cidr            = var.vcn_cidr
  common_tags         = local.common_tags

  # Network resources from network module
  master_subnet_id          = module.network.master_subnet_id
  worker_subnet_id          = module.network.worker_subnet_id
  network_security_group_id = module.network.network_security_group_id
}

resource "oci_network_load_balancer_backend" "master_http_backend" {
  backend_set_name         = module.network.gateway_http_backend_set_name
  network_load_balancer_id = module.network.nlb_id
  port                     = 30080
  target_id                = module.compute_instances.kube_server_master_id

  depends_on = [
    module.network,
    module.compute_instances
  ]
}

resource "oci_network_load_balancer_backend" "master_https_backend" {
  backend_set_name         = module.network.gateway_https_backend_set_name
  network_load_balancer_id = module.network.nlb_id
  port                     = 30443
  target_id                = module.compute_instances.kube_server_master_id

  depends_on = [
    module.network,
    module.compute_instances
  ]
}

# Worker node backends
resource "oci_network_load_balancer_backend" "worker_http_backends" {
  count                    = var.worker_count
  backend_set_name         = module.network.gateway_http_backend_set_name
  network_load_balancer_id = module.network.nlb_id
  port                     = 30080
  target_id                = module.compute_instances.kube_server_worker_ids[count.index]

  depends_on = [
    module.network,
    module.compute_instances
  ]
}

resource "oci_network_load_balancer_backend" "worker_https_backends" {
  count                    = var.worker_count
  backend_set_name         = module.network.gateway_https_backend_set_name
  network_load_balancer_id = module.network.nlb_id
  port                     = 30443
  target_id                = module.compute_instances.kube_server_worker_ids[count.index]

  depends_on = [
    module.network,
    module.compute_instances
  ]
}
