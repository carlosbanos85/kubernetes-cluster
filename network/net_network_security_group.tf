resource "oci_core_network_security_group" "kube_server_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-nsg"

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "network-security-group"
  })
}

resource "oci_core_network_security_group_security_rule" "kube_server_nsg_ingress" {
  network_security_group_id = oci_core_network_security_group.kube_server_nsg.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = oci_core_network_security_group.kube_server_nsg.id
  source_type               = "NETWORK_SECURITY_GROUP"
  description               = "Allow all traffic within the NSG"
}

resource "oci_core_network_security_group_security_rule" "kube_server_nsg_egress" {
  network_security_group_id = oci_core_network_security_group.kube_server_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  description               = "Allow all outbound traffic"
}
