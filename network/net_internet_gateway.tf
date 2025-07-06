resource "oci_core_internet_gateway" "kube_server_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-internet-gateway"
  enabled        = true

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "internet-gateway"
  })
}
