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
    subnet_id                 = var.api_subnet_id
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

      # Load configuration files
      sysctl_config  = file("${path.root}/compute-instances/cloud-init-config/configs/k3s-cilium.conf")
      modules_config = file("${path.root}/compute-instances/cloud-init-config/configs/k3s-cilium-modules.conf")

      # Load service configurations
      k3s_service_config       = file("${path.root}/compute-instances/cloud-init-config/configs/k3s-install.service")
      helm_service_config      = file("${path.root}/compute-instances/cloud-init-config/configs/helm-install.service")
      cilium_service_config    = file("${path.root}/compute-instances/cloud-init-config/configs/cilium-install.service")
      bgp_setup_service_config = file("${path.root}/compute-instances/cloud-init-config/configs/bgp-setup.service")

      # Load and template scripts
      k3s_install_script = templatefile("${path.root}/compute-instances/cloud-init-config/scripts/k3s-install.sh", {
        hostname       = var.master_hostname
        cluster_domain = var.cluster_domain
      })

      helm_install_script = file("${path.root}/compute-instances/cloud-init-config/scripts/helm-install.sh")

      cilium_install_script = templatefile("${path.root}/compute-instances/cloud-init-config/scripts/cilium-install.sh", {
        hostname       = var.master_hostname
        cilium_version = var.cilium_version
      })

      # Template the Cilium values.yaml file
      cilium_values_config = templatefile("${path.root}/compute-instances/cloud-init-config/configs/cilium-values.yaml", {
        cluster_name               = var.project_name
        master_ip                  = var.master_hostname # Use hostname for internal communication
        ingress_controller_enabled = var.enable_ingress_controller
        lb_ip_pool                 = var.cilium_lb_ip_pool != "" ? var.cilium_lb_ip_pool : "192.168.101.25"
      })

      bgp_setup_script = templatefile("${path.root}/compute-instances/cloud-init-config/scripts/bgp-setup.sh", {
        hostname           = var.master_hostname
        bgp_announced_cidr = var.bgp_announced_cidr
        cluster_name       = var.project_name
      })
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
