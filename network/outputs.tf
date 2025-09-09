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

output "master_subnet_id" {
  description = "OCID of the master subnet"
  value       = oci_core_subnet.master_subnet.id
}

output "worker_subnet_id" {
  description = "OCID of the worker subnet"
  value       = oci_core_subnet.worker_subnet.id
}

output "master_security_list_id" {
  description = "OCID of the master security list"
  value       = oci_core_security_list.master_security_list.id
}

output "worker_security_list_id" {
  description = "OCID of the worker security list"
  value       = oci_core_security_list.worker_security_list.id
}
