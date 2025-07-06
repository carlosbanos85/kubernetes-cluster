# Public Subnet
resource "oci_core_subnet" "kube_server_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.kube_server_vcn.id
  display_name               = "${var.project_name}-public-subnet"
  cidr_block                 = var.subnet_cidr
  dns_label                  = local.subnet_dns_label
  security_list_ids          = [oci_core_vcn.kube_server_vcn.default_security_list_id]
  route_table_id             = oci_core_vcn.kube_server_vcn.default_route_table_id
  dhcp_options_id            = oci_core_vcn.kube_server_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "subnet"
    Scope     = "public"
  })
}
