resource "oci_core_vcn" "kube_server_vcn" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-vcn"
  cidr_block     = var.vcn_cidr
  dns_label      = local.vcn_dns_label

  freeform_tags = var.common_tags
}
