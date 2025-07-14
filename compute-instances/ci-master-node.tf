resource "oci_core_instance" "kube_server_master" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = local.master_hostname
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${local.master_hostname}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = var.master_hostname
    nsg_ids                   = [var.network_security_group_id]
  }

  source_details {
    source_type             = "image"
    source_id               = var.instance_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.root}/compute-instances/cloud-init-config/cloud-init-master.yaml", {
      hostname       = var.master_hostname
      cluster_domain = var.cluster_domain
      cluster_token  = var.cluster_token
      cilium_version = var.cilium_version
      vcn_cidr       = var.vcn_cidr
    }))
  }

  freeform_tags = merge(var.common_tags, {
    Component = "compute"
    Role      = "master"
    Node      = var.master_hostname
    Type      = "kube-server-control-plane"
  })

  preserve_boot_volume = false

  # Ignore changes to user_data to prevent unnecessary recreations
  lifecycle {
    ignore_changes = [metadata["user_data"]]
  }
}
