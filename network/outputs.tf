output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.kube_server_vcn.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.kube_server_vcn.cidr_blocks[0]
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.kube_server_igw.id
}

output "network_security_group_id" {
  description = "OCID of the Network Security Group"
  value       = oci_core_network_security_group.kube_server_nsg.id
}

output "vcn_dns_label" {
  description = "DNS label of the VCN"
  value       = oci_core_vcn.kube_server_vcn.dns_label
}

output "api_subnet_id" {
  description = "OCID of the API subnet"
  value       = oci_core_subnet.kube_server_api_subnet.id
}

output "worker_subnet_id" {
  description = "OCID of the worker subnet"
  value       = oci_core_subnet.kube_server_worker_subnet.id
}

output "api_subnet_cidr" {
  description = "CIDR block of the API subnet"
  value       = oci_core_subnet.kube_server_api_subnet.cidr_block
}

output "worker_subnet_cidr" {
  description = "CIDR block of the worker subnet"
  value       = oci_core_subnet.kube_server_worker_subnet.cidr_block
}

output "drg_id" {
  description = "OCID of the Dynamic Routing Gateway"
  value       = oci_core_drg.kube_server_drg.id
}

output "drg_attachment_id" {
  description = "OCID of the DRG attachment"
  value       = oci_core_drg_attachment.kube_server_drg_attachment.id
}
