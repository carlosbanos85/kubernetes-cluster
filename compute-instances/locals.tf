locals {
  master_hostname = "${var.project_name}-master"

  # Define Cilium configuration variables
  cilium_config = {
    cluster_name      = var.project_name
    master_ip         = var.master_hostname # This will be the internal hostname
    master_private_ip = ""                  # Will be populated after instance creation

    bgp_enabled              = true
    bgp_announced_cidr       = var.bgp_announced_cidr
    l2_announcements_enabled = false # Must be false in OCI
    hubble_enabled           = true
    gateway_api_enabled      = true
  }

  bgp_config = {
    # OCI DRG always uses ASN 31898 (Oracle's ASN)
    drg_asn = 31898

    # Local ASN for Cilium BGP speakers (private ASN range 64512-65534)
    local_asn = 65001

    # DRG peer IP calculation:
    # For a VCN with CIDR 10.0.0.0/16, the DRG peer IP is typically 10.0.0.1
    # This is the VCN's gateway IP that the DRG uses for BGP peering
    drg_peer_ip = cidrhost(var.vcn_cidr, 1)
  }

}
