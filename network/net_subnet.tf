# Master Subnet (API Endpoints)
resource "oci_core_subnet" "master_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.kube_server_vcn.id
  display_name               = "${var.project_name}-master-subnet"
  cidr_block                 = var.master_subnet_cidr
  dns_label                  = "master"
  security_list_ids          = [oci_core_security_list.master_security_list.id]
  route_table_id             = oci_core_vcn.kube_server_vcn.default_route_table_id
  dhcp_options_id            = oci_core_vcn.kube_server_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "subnet"
    Scope     = "master"
  })
}

# Worker Subnet
resource "oci_core_subnet" "worker_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.kube_server_vcn.id
  display_name               = "${var.project_name}-worker-subnet"
  cidr_block                 = var.worker_subnet_cidr
  dns_label                  = "worker"
  security_list_ids          = [oci_core_security_list.worker_security_list.id]
  route_table_id             = oci_core_vcn.kube_server_vcn.default_route_table_id
  dhcp_options_id            = oci_core_vcn.kube_server_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "subnet"
    Scope     = "worker"
  })
}

# Load Balancer Subnet
resource "oci_core_subnet" "lb_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.kube_server_vcn.id
  display_name               = "${var.project_name}-lb-subnet"
  cidr_block                 = var.lb_subnet_cidr
  dns_label                  = "lb"
  security_list_ids          = [oci_core_security_list.lb_security_list.id]
  route_table_id             = oci_core_vcn.kube_server_vcn.default_route_table_id
  dhcp_options_id            = oci_core_vcn.kube_server_vcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = false

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "subnet"
    Scope     = "load-balancer"
  })
}
