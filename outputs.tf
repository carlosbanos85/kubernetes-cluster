# Network Module Outputs
output "network" {
  description = "Network infrastructure details from network module"
  value = {
    vcn_id                    = module.network.vcn_id
    vcn_cidr                  = module.network.vcn_cidr
    master_subnet_id          = module.network.master_subnet_id
    worker_subnet_id          = module.network.worker_subnet_id
    internet_gateway_id       = module.network.internet_gateway_id
    network_security_group_id = module.network.network_security_group_id
    vcn_dns_label             = module.network.vcn_dns_label
    master_security_list_id   = module.network.master_security_list_id
    worker_security_list_id   = module.network.worker_security_list_id
  }
}

# Compute Module Outputs
output "compute" {
  description = "Compute infrastructure details from compute module"
  value = {
    master_id                = module.compute_instances.kube_server_master_id
    master_public_ip         = module.compute_instances.kube_server_master_public_ip
    master_private_ip        = module.compute_instances.kube_server_master_private_ip
    master_hostname          = module.compute_instances.kube_server_master_hostname
    worker_ids               = module.compute_instances.kube_server_worker_ids
    workers_public_ips       = module.compute_instances.kube_server_workers_public_ips
    workers_private_ips      = module.compute_instances.kube_server_workers_private_ips
    workers_hostnames        = module.compute_instances.kube_server_workers_hostnames
    master_instance_details  = module.compute_instances.master_instance_details
    worker_instances_details = module.compute_instances.worker_instances_details
  }
}

# Direct access outputs for convenience
output "kube_server_master_public_ip" {
  description = "Public IP address of the K3s master node"
  value       = module.compute_instances.kube_server_master_public_ip
}

output "kube_server_master_private_ip" {
  description = "Private IP address of the K3s master node"
  value       = module.compute_instances.kube_server_master_private_ip
}

output "kube_server_workers_public_ips" {
  description = "List of public IP addresses of the K3s worker nodes"
  value       = module.compute_instances.kube_server_workers_public_ips
}

output "kube_server_workers_private_ips" {
  description = "List of private IP addresses of the K3s worker nodes"
  value       = module.compute_instances.kube_server_workers_private_ips
}

# Connection Information
output "ssh_connection_commands" {
  description = "SSH connection commands for all nodes"
  value = {
    master = "ssh ubuntu@${module.compute_instances.kube_server_master_public_ip}"
    workers = [
      for ip in module.compute_instances.kube_server_workers_public_ips :
      "ssh ubuntu@${ip}"
    ]
  }
}

output "kube_server_api_endpoint" {
  description = "K3s API server endpoint URL"
  value       = "https://${module.compute_instances.kube_server_master_public_ip}:6443"
}

output "kubeconfig_command" {
  description = "Command to download and configure kubeconfig for kubectl access"
  value       = "scp ubuntu@${module.compute_instances.kube_server_master_public_ip}:/etc/rancher/k3s/k3s.yaml ~/.kube/config && sed -i 's/127.0.0.1/${module.compute_instances.kube_server_master_public_ip}/g' ~/.kube/config"
}

# OCI CCM Information
output "oci_ccm_setup_commands" {
  description = "Commands to verify OCI Cloud Controller Manager"
  value = {
    check_ccm_pods      = "kubectl get pods -n kube-system -l k8s-app=oci-cloud-controller-manager"
    check_ccm_logs      = "kubectl logs -n kube-system -l k8s-app=oci-cloud-controller-manager"
    check_node_labels   = "kubectl get nodes --show-labels"
    check_loadbalancers = "kubectl get svc --all-namespaces -o wide"
  }
}

# LoadBalancer Services Information
output "loadbalancer_examples" {
  description = "Example commands for LoadBalancer services"
  value = {
    deploy_nginx     = "kubectl apply -f applications/nginx-loadbalancer.yaml"
    deploy_rust      = "kubectl apply -f applications/rust-loadbalancer.yaml"
    deploy_ingress   = "kubectl apply -f applications/ingress-with-loadbalancer.yaml"
    check_services   = "kubectl get svc -o wide"
    get_external_ips = "kubectl get svc -o jsonpath='{.items[?(@.spec.type==\"LoadBalancer\")].status.loadBalancer.ingress[0].ip}'"
  }
}

# Cluster Summary
output "cluster_summary" {
  description = "Comprehensive summary of the K3s cluster with OCI CCM"
  value = {
    cluster_name        = var.project_name
    environment         = var.environment
    region              = var.region != "" ? var.region : "from-oci-config"
    availability_domain = local.availability_domain

    # Node information
    master_count = 1
    worker_count = var.worker_count
    total_nodes  = 1 + var.worker_count

    # Resource allocation
    ocpus_per_instance   = var.instance_ocpus
    memory_per_instance  = var.instance_memory_gb
    storage_per_instance = var.boot_volume_size_gb
    total_ocpus          = (1 + var.worker_count) * var.instance_ocpus
    total_memory_gb      = (1 + var.worker_count) * var.instance_memory_gb
    total_storage_gb     = (1 + var.worker_count) * var.boot_volume_size_gb

    # Network configuration
    vcn_cidr           = var.vcn_cidr
    master_subnet_cidr = var.master_subnet_cidr
    worker_subnet_cidr = var.worker_subnet_cidr

    # Architecture
    load_balancer_type = "OCI Cloud Controller Manager (CCM)"
    cni                = "Cilium ${var.cilium_version}"
    cluster_domain     = var.cluster_domain

    # Free tier utilization
    free_tier_ocpu_usage    = "${(1 + var.worker_count) * var.instance_ocpus}/4"
    free_tier_memory_usage  = "${(1 + var.worker_count) * var.instance_memory_gb}/24"
    free_tier_storage_usage = "${(1 + var.worker_count) * var.boot_volume_size_gb}/200"
  }
}

# Status Check Commands
output "cluster_status_commands" {
  description = "Useful commands for checking cluster status and health"
  value = {
    # Cloud-init status
    cloud_init_master = "ssh ubuntu@${module.compute_instances.kube_server_master_public_ip} 'sudo cloud-init status --long'"
    cloud_init_workers = [
      for ip in module.compute_instances.kube_server_workers_public_ips :
      "ssh ubuntu@${ip} 'sudo cloud-init status --long'"
    ]

    # Cluster status
    cluster_nodes = "kubectl get nodes -o wide"
    cluster_pods  = "kubectl get pods --all-namespaces"
    cluster_info  = "kubectl cluster-info"

    # Service status
    master_k3s_status = "ssh ubuntu@${module.compute_instances.kube_server_master_public_ip} 'sudo systemctl status k3s'"
    worker_k3s_status = [
      for ip in module.compute_instances.kube_server_workers_public_ips :
      "ssh ubuntu@${ip} 'sudo systemctl status k3s-agent'"
    ]

    # OCI CCM status
    oci_ccm_status = "kubectl get pods -n kube-system -l k8s-app=oci-cloud-controller-manager"
    oci_ccm_logs   = "kubectl logs -n kube-system -l k8s-app=oci-cloud-controller-manager"

    # Load Balancer services
    check_services     = "kubectl get svc --all-namespaces -o wide"
    check_external_ips = "kubectl get svc -o jsonpath='{.items[?(@.spec.type==\"LoadBalancer\")].status.loadBalancer.ingress[0].ip}'"

    # Logs
    master_logs = "ssh ubuntu@${module.compute_instances.kube_server_master_public_ip} 'sudo journalctl -u k3s -f'"
    worker_logs = [
      for ip in module.compute_instances.kube_server_workers_public_ips :
      "ssh ubuntu@${ip} 'sudo journalctl -u k3s-agent -f'"
    ]
  }
}

# Deployment Information
output "deployment_info" {
  description = "Important information about the OCI CCM deployment and next steps"
  value = {
    architecture_change     = "Moved from Gateway API + NodePort to OCI Cloud Controller Manager with LoadBalancer services"
    cluster_ready_time      = "Cluster will be ready in approximately 10-15 minutes after apply (includes OCI CCM setup)"
    access_instructions     = "Run: eval \"$(terraform output -raw kubeconfig_command)\" to configure kubectl"
    troubleshooting_logs    = "/var/log/cloud-init-output.log on each instance"
    k3s_config_location     = "/etc/rancher/k3s/k3s.yaml on master node"
    oci_ccm_config_location = "/tmp/oci/cloud-config.yaml on master node"

    # Quick start commands
    quick_commands = {
      check_cluster       = "kubectl get nodes"
      check_oci_ccm       = "kubectl get pods -n kube-system -l k8s-app=oci-cloud-controller-manager"
      deploy_nginx        = "kubectl apply -f applications/nginx-loadbalancer.yaml"
      check_loadbalancers = "kubectl get svc -o wide"
      get_external_ips    = "kubectl get svc -o jsonpath='{.items[?(@.spec.type==\"LoadBalancer\")].status.loadBalancer.ingress[0].ip}'"
    }

    # Next steps
    recommended_next_steps = [
      "1. Verify cluster: kubectl get nodes",
      "2. Check OCI CCM: kubectl get pods -n kube-system -l k8s-app=oci-cloud-controller-manager",
      "3. Deploy test app: kubectl apply -f applications/nginx-loadbalancer.yaml",
      "4. Check external IP: kubectl get svc nginx-loadbalancer",
      "5. Test LoadBalancer: curl <EXTERNAL-IP>",
      "6. Deploy ingress controller: kubectl apply -f applications/ingress-with-loadbalancer.yaml"
    ]
  }
}

# Administrative Information
output "admin_info" {
  description = "Administrative information for cluster management"
  value = {
    terraform_workspace = terraform.workspace
    created_at          = timestamp()
    managed_by          = "kube-server-oci-terraform"
    architecture        = "K3s + Cilium + OCI CCM"

    # Resource identifiers
    compartment_ocid = var.compartment_id
    vcn_id           = module.network.vcn_id
    master_subnet_id = module.network.master_subnet_id
    worker_subnet_id = module.network.worker_subnet_id

    # Configuration
    project_name   = var.project_name
    environment    = var.environment
    instance_shape = var.instance_shape
    worker_count   = var.worker_count
    cilium_version = var.cilium_version
  }
}
