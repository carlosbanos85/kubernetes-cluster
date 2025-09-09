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

  # Internal cluster communication
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    description = "Internal cluster communication"
  }

  # Allow OCI Load Balancer health checks (from OCI LB subnets)
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "OCI LB Health Checks - HTTP"
    tcp_options {
      min = 10256
      max = 10256
    }
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

  # Internal cluster communication
  ingress_security_rules {
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
    description = "Internal cluster communication"
  }

  # Allow OCI Load Balancer health checks (from OCI LB subnets)
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6"
    description = "OCI LB Health Checks - HTTP"
    tcp_options {
      min = 10256
      max = 10256
    }
  }

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "security-list"
    Scope     = "worker"
  })
}
