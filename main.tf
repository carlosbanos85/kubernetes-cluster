# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Get the latest Oracle Linux 9 image for ARM64
data "oci_core_images" "ol9_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "9"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}


# Network Module
module "network" {
  source = "./network"

  # Pass variables to network module
  compartment_id = var.compartment_id
  project_name   = var.project_name
  environment    = var.environment
  vcn_cidr       = var.vcn_cidr
  subnet_cidr    = var.subnet_cidr
  common_tags    = local.common_tags
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
  k3s_disable_flags   = var.k3s_disable_flags
  cluster_domain      = var.cluster_domain
  master_hostname     = var.master_hostname
  worker_hostname     = var.worker_hostname
  vcn_cidr            = var.vcn_cidr
  common_tags         = local.common_tags

  # Network resources from network module
  subnet_id                 = module.network.subnet_id
  network_security_group_id = module.network.network_security_group_id
}
