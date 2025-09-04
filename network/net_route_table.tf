# API Subnet Route Table
resource "oci_core_route_table" "kube_server_api_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-api-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.kube_server_igw.id
    description       = "Default route to Internet Gateway"
  }

  # Route to DRG for BGP announcements
  route_rules {
    destination       = var.bgp_announced_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.kube_server_drg.id
    description       = "Route for BGP announced IPs"
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "route-table"
    Scope     = "api"
  })
}

# Worker Subnet Route Table
resource "oci_core_route_table" "kube_server_worker_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-worker-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.kube_server_igw.id
    description       = "Default route to Internet Gateway"
  }

  # Route to DRG for BGP announcements
  route_rules {
    destination       = var.bgp_announced_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.kube_server_drg.id
    description       = "Route for BGP announced IPs"
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "route-table"
    Scope     = "worker"
  })
}

# Load Balancer Subnet Route Table
resource "oci_core_route_table" "kube_server_lb_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-lb-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.kube_server_igw.id
    description       = "Default route to Internet Gateway"
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "route-table"
    Scope     = "loadbalancer"
  })
}
