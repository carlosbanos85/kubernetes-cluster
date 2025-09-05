locals {
  vcn_dns_label    = replace(var.project_name, "-", "")
  subnet_dns_label = "${local.vcn_dns_label}subnet"

  # Kube server security list rules
  kube_server_ingress_rules = [

    # SSH access
    {
      description = "SSH access"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 22
      max_port    = 22
    },

    # Kube Server API server
    {
      description = "Kube Server API server"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 6443
      max_port    = 6443
    },

    # Kubelet API
    {
      description = "Kubelet API"
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 10250
      max_port    = 10250
    },

    # Cilium health checks
    {
      description = "Cilium health checks"
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 4240
      max_port    = 4240
    },

    # Cilium Hubble gRPC API
    {
      description = "Cilium Hubble gRPC API"
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 4244
      max_port    = 4244
    },

    # Cilium Hubble Relay
    {
      description = "Cilium Hubble Relay"
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 4245
      max_port    = 4245
    },

    # Cilium VXLAN tunnel
    {
      description = "Cilium VXLAN tunnel"
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol    = "17" # UDP
      min_port    = 8472
      max_port    = 8472
    },

    # HTTP traffic
    {
      description = "HTTP traffic"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 80
      max_port    = 80
    },

    # HTTPS traffic
    {
      description = "HTTPS traffic"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 443
      max_port    = 443
    },
  ]
}
