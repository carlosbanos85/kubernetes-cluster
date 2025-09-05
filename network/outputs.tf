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

output "lb_subnet_id" {
  description = "OCID of the load balancer subnet"
  value       = oci_core_subnet.lb_subnet.id
}

output "gateway_http_backend_set_name" {
  description = "Name of the Gateway HTTP backend set"
  value       = oci_network_load_balancer_backend_set.gateway_http_backend_set.name
}

output "gateway_https_backend_set_name" {
  description = "Name of the Gateway HTTPS backend set"
  value       = oci_network_load_balancer_backend_set.gateway_https_backend_set.name
}

# Keep all your existing outputs...
output "nlb_id" {
  description = "OCID of the Network Load Balancer"
  value       = oci_network_load_balancer_network_load_balancer.kube_server_nlb.id
}

output "nlb_public_ip" {
  description = "Public IP of the Network Load Balancer"
  value       = oci_network_load_balancer_network_load_balancer.kube_server_nlb.ip_addresses[0].ip_address
}
