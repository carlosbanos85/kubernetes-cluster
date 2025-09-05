# Network Module Outputs
output "network" {
  description = "Network infrastructure details from network module"
  value = {
    vcn_id                    = module.network.vcn_id
    vcn_cidr                  = module.network.vcn_cidr
    master_subnet_id          = module.network.master_subnet_id
    worker_subnet_id          = module.network.worker_subnet_id
    lb_subnet_id              = module.network.lb_subnet_id
    internet_gateway_id       = module.network.internet_gateway_id
    network_security_group_id = module.network.network_security_group_id
    vcn_dns_label             = module.network.vcn_dns_label
    nlb_public_ip             = module.network.nlb_public_ip
    nlb_id                    = module.network.nlb_id
  }
}

# Gateway API Access Information
output "gateway_api_endpoints" {
  description = "Gateway API access endpoints"
  value = {
    nlb_public_ip  = module.network.nlb_public_ip
    http_endpoint  = "http://${module.network.nlb_public_ip}"
    https_endpoint = "https://${module.network.nlb_public_ip}"
  }
}

output "gateway_api_setup_commands" {
  description = "Commands to set up Gateway API resources"
  value = {
    install_crds = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml"
    check_status = "kubectl get gatewayclasses,gateways,httproutes -o wide"
    test_gateway = "curl -H 'Host: api.example.com' http://${module.network.nlb_public_ip}"
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

# Resource Summary
output "cluster_summary" {
  description = "Comprehensive summary of the K3s cluster resources"
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

    # K3s configuration
    cluster_domain = var.cluster_domain

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
    master_kube_server_status = "ssh ubuntu@${module.compute_instances.kube_server_master_public_ip} 'sudo systemctl status k3s'"
    worker_kube_server_status = [
      for ip in module.compute_instances.kube_server_workers_public_ips :
      "ssh ubuntu@${ip} 'sudo systemctl status k3s-agent'"
    ]

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
  description = "Important information about the deployment and next steps"
  value = {
    cluster_ready_time          = "Cluster will be ready in approximately 5-10 minutes after apply"
    access_instructions         = "Run: eval \"$(terraform output -raw kubeconfig_command)\" to configure kubectl"
    troubleshooting_logs        = "/var/log/cloud-init-output.log on each instance"
    kube_server_config_location = "/etc/rancher/k3s/k3s.yaml on master node"
    node_token_location         = "/var/lib/rancher/k3s/server/node-token on master node"
    oci_config_profile          = "Using OCI config profile: [US]"

    # Quick start commands
    quick_commands = {
      check_nodes    = "kubectl get nodes"
      check_pods     = "kubectl get pods -A"
      ssh_master     = "ssh ubuntu@${module.compute_instances.kube_server_master_public_ip}"
      health_check   = "./scripts/cluster-health.sh all"
      backup_cluster = "./scripts/backup-restore.sh full"
    }

    # Next steps
    recommended_next_steps = [
      "1. Verify cluster: kubectl get nodes",
      "2. Deploy test app: kubectl create deployment nginx --image=nginx",
      "3. Install ingress: kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml",
      "4. Set up monitoring: echo 'enable_monitoring = true' >> terraform.tfvars && terraform apply",
      "5. Create backup: ./scripts/backup-restore.sh full"
    ]
  }
}

# URLs and Endpoints (when monitoring is enabled)
output "service_endpoints" {
  description = "Service endpoints for various cluster services"
  value = {
    kube_server_api = "https://${module.compute_instances.kube_server_master_public_ip}:6443"
    grafana         = "http://${module.compute_instances.kube_server_master_public_ip}:30300 (when monitoring enabled)"
    prometheus      = "http://${module.compute_instances.kube_server_master_public_ip}:30900 (when monitoring enabled)"
  }
}

# Administrative Information
output "admin_info" {
  description = "Administrative information for cluster management"
  value = {
    terraform_workspace = terraform.workspace
    created_at          = timestamp()
    managed_by          = "kube-server-oci-terraform"

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
  }
}

output "nlb_backends" {
  description = "NLB backend configuration"
  value = {
    master_http_backend   = oci_network_load_balancer_backend.master_http_backend.id
    master_https_backend  = oci_network_load_balancer_backend.master_https_backend.id
    worker_http_backends  = oci_network_load_balancer_backend.worker_http_backends[*].id
    worker_https_backends = oci_network_load_balancer_backend.worker_https_backends[*].id
  }
}
