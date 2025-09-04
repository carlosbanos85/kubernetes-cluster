# API Endpoint Subnet (Master nodes)
resource "oci_core_subnet" "kube_server_api_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.kube_server_vcn.id
  display_name               = "${var.project_name}-api-subnet"
  cidr_block                 = var.api_subnet_cidr
  dns_label                  = "${local.vcn_dns_label}api"
  security_list_ids          = [oci_core_security_list.kube_server_api_security_list.id]
  route_table_id             = oci_core_route_table.kube_server_api_route_table.id
  dhcp_options_id            = oci_core_vcn.kube_server_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "subnet"
    Scope     = "api"
  })
}

# Worker Nodes Subnet
resource "oci_core_subnet" "kube_server_worker_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.kube_server_vcn.id
  display_name               = "${var.project_name}-worker-subnet"
  cidr_block                 = var.worker_subnet_cidr
  dns_label                  = "${local.vcn_dns_label}worker"
  security_list_ids          = [oci_core_security_list.kube_server_worker_security_list.id]
  route_table_id             = oci_core_route_table.kube_server_worker_route_table.id
  dhcp_options_id            = oci_core_vcn.kube_server_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "subnet"
    Scope     = "worker"
  })
}
