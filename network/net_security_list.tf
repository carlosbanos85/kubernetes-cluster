# API Subnet Security List
resource "oci_core_security_list" "kube_server_api_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-api-security-list"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Allow all outbound traffic"
  }

  # SSH access
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "SSH access"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Kubernetes API server
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "Kubernetes API server"
    tcp_options {
      min = 6443
      max = 6443
    }
  }

  # BGP peering with DRG
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "BGP peering"
    tcp_options {
      min = 179
      max = 179
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
    Scope     = "api"
  })
}

# Worker Subnet Security List
resource "oci_core_security_list" "kube_server_worker_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-worker-security-list"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Allow all outbound traffic"
  }

  # SSH access
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "SSH access"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Kubelet API
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "Kubelet API"
    tcp_options {
      min = 10250
      max = 10250
    }
  }

  # BGP peering
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "BGP peering"
    tcp_options {
      min = 179
      max = 179
    }
  }

  # Cilium VXLAN
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "17"
    description = "Cilium VXLAN tunnel"
    udp_options {
      min = 8472
      max = 8472
    }
  }

  # Application traffic (from DRG via BGP)
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "HTTP traffic"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "HTTPS traffic"
    tcp_options {
      min = 443
      max = 443
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
    Scope     = "worker"
  })
}

# Load Balancer Subnet Security List
resource "oci_core_security_list" "kube_server_lb_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-lb-security-list"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Allow all outbound traffic"
  }

  # HTTP/HTTPS for load balancer IPs
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "HTTP traffic"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "HTTPS traffic"
    tcp_options {
      min = 443
      max = 443
    }
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "security-list"
    Scope     = "loadbalancer"
  })
}
