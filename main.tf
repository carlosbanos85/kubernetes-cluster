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

  # OCI CCM Configuration
  region                  = var.region
  vcn_id                  = module.network.vcn_id
  master_security_list_id = module.network.master_security_list_id
  worker_security_list_id = module.network.worker_security_list_id
}
