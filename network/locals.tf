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

    # Kube Server kubelet
    {
      description = "Kube Server kubelet"
      source      = var.vcn_cidr
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 10250
      max_port    = 10250
    },

    # Flannel VXLAN
    {
      description = "Flannel VXLAN"
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

    # NodePort services range
    {
      description = "NodePort services"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = "6" # TCP
      min_port    = 30000
      max_port    = 32767
    }
  ]
}
