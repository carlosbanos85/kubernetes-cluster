# Dynamic Routing Gateway
resource "oci_core_drg" "kube_server_drg" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-drg"

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "drg"
  })
}

# DRG Attachment to VCN
resource "oci_core_drg_attachment" "kube_server_drg_attachment" {
  drg_id = oci_core_drg.kube_server_drg.id

  network_details {
    id   = oci_core_vcn.kube_server_vcn.id
    type = "VCN"
  }

  display_name = "${var.project_name}-drg-attachment"

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "drg-attachment"
  })
}
