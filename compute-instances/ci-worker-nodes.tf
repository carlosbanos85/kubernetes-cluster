resource "oci_core_instance" "kube_server_workers" {
  count               = var.worker_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  display_name        = "${var.project_name}-worker-${count.index + 1}"
  shape               = var.instance_shape

  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_memory_gb
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${var.project_name}-worker-${count.index + 1}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = "${var.worker_hostname}-${count.index + 1}"
    nsg_ids                   = [var.network_security_group_id]
  }

  source_details {
    source_type             = "image"
    source_id               = var.instance_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_gb
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.root}/compute-instances/cloud-init-config/cloud-init-worker.yaml", {
      hostname         = "${var.worker_hostname}-${count.index + 1}"
      cluster_domain   = var.cluster_domain
      master_ip        = oci_core_instance.kube_server_master.private_ip
      master_public_ip = oci_core_instance.kube_server_master.public_ip
      cluster_token    = var.cluster_token
      vcn_cidr         = var.vcn_cidr
    }))
  }

  freeform_tags = merge(var.common_tags, {
    Component = "compute"
    Role      = "worker"
    Node      = "${var.worker_hostname}-${count.index + 1}"
    Type      = "${var.worker_hostname}-node"
  })

  preserve_boot_volume = false
  depends_on           = [oci_core_instance.kube_server_master]

  # Ignore changes to user_data to prevent unnecessary recreations
  lifecycle {
    ignore_changes = [metadata["user_data"]]
  }
}
