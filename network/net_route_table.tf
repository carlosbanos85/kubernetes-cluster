resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.kube_server_vcn.default_route_table_id
  display_name               = "${var.project_name}-default-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.kube_server_igw.id
    description       = "Default route to Internet Gateway"
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "route-table"
    Scope     = "default"
  })
}
