output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_vcn.kube_server_vcn.id
}

output "vcn_cidr" {
  description = "CIDR block of the VCN"
  value       = oci_core_vcn.kube_server_vcn.cidr_blocks[0]
}

output "subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.kube_server_subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = oci_core_subnet.kube_server_subnet.cidr_block
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.kube_server_igw.id
}

output "security_list_id" {
  description = "OCID of the security list"
  value       = oci_core_default_security_list.kube_server_security_list.id
}

output "network_security_group_id" {
  description = "OCID of the Network Security Group"
  value       = oci_core_network_security_group.kube_server_nsg.id
}

output "route_table_id" {
  description = "OCID of the route table"
  value       = oci_core_default_route_table.kube_server_route_table.id
}

output "vcn_dns_label" {
  description = "DNS label of the VCN"
  value       = oci_core_vcn.kube_server_vcn.dns_label
}

output "subnet_dns_label" {
  description = "DNS label of the subnet"
  value       = oci_core_subnet.kube_server_subnet.dns_label
}
