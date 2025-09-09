# Master Security List
resource "oci_core_security_list" "master_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-master-security-list"

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

  # Gateway API NodePorts from LB subnet
  ingress_security_rules {
    source      = var.lb_subnet_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "Gateway NodePorts from LB"
    tcp_options {
      min = 30080
      max = 30443
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
    Scope     = "master"
  })
}

# Worker Security List
resource "oci_core_security_list" "worker_security_list" {
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

  # Gateway API NodePorts from LB subnet
  ingress_security_rules {
    source      = var.lb_subnet_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "Gateway NodePorts from LB"
    tcp_options {
      min = 30000
      max = 32767
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

# Load Balancer Security List
resource "oci_core_security_list" "lb_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.kube_server_vcn.id
  display_name   = "${var.project_name}-lb-security-list"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    description      = "Allow all outbound traffic"
  }

  # HTTP traffic
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

  # HTTPS traffic
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
    Scope     = "load-balancer"
  })
}
