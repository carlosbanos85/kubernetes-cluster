resource "oci_core_default_security_list" "kube_server_security_list" {
  manage_default_resource_id = oci_core_vcn.kube_server_vcn.default_security_list_id
  display_name               = "${var.project_name}-security-list"

  # Egress rules - allow all outbound traffic
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Allow all outbound traffic"
  }

  # Dynamic ingress rules for Kube Server ports
  dynamic "ingress_security_rules" {
    for_each = local.kube_server_ingress_rules
    content {
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      protocol    = ingress_security_rules.value.protocol
      description = ingress_security_rules.value.description

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.protocol == "6" ? [1] : []
        content {
          min = ingress_security_rules.value.min_port
          max = ingress_security_rules.value.max_port
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.protocol == "17" ? [1] : []
        content {
          min = ingress_security_rules.value.min_port
          max = ingress_security_rules.value.max_port
        }
      }
    }
  }

  # Internal cluster communication
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    description = "Internal cluster communication"
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "security-list"
  })
}
