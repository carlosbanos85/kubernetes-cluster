# Master Node Outputs
output "kube_server_master_id" {
  description = "OCID of the kube server master node"
  value       = oci_core_instance.kube_server_master.id
}

output "kube_server_master_public_ip" {
  description = "Public IP of the kube server master node"
  value       = oci_core_instance.kube_server_master.public_ip
}

output "kube_server_master_private_ip" {
  description = "Private IP of the kube server master node"
  value       = oci_core_instance.kube_server_master.private_ip
}

output "kube_server_master_hostname" {
  description = "Hostname of the kube server master node"
  value       = oci_core_instance.kube_server_master.display_name
}

# Worker Nodes Outputs
output "kube_server_worker_ids" {
  description = "OCIDs of the kube server worker nodes"
  value       = oci_core_instance.kube_server_workers[*].id
}

output "kube_server_workers_public_ips" {
  description = "Public IPs of the kube server worker nodes"
  value       = oci_core_instance.kube_server_workers[*].public_ip
}

output "kube_server_workers_private_ips" {
  description = "Private IPs of the kube server worker nodes"
  value       = oci_core_instance.kube_server_workers[*].private_ip
}

output "kube_server_workers_hostnames" {
  description = "Hostnames of the kube server worker nodes"
  value       = oci_core_instance.kube_server_workers[*].display_name
}

# Additional instance details
output "master_instance_details" {
  description = "Detailed information about the master instance"
  value = {
    ocid                = oci_core_instance.kube_server_master.id
    display_name        = oci_core_instance.kube_server_master.display_name
    shape               = oci_core_instance.kube_server_master.shape
    availability_domain = oci_core_instance.kube_server_master.availability_domain
    public_ip           = oci_core_instance.kube_server_master.public_ip
    private_ip          = oci_core_instance.kube_server_master.private_ip
    state               = oci_core_instance.kube_server_master.state
    time_created        = oci_core_instance.kube_server_master.time_created
  }
}

output "worker_instances_details" {
  description = "Detailed information about worker instances"
  value = [
    for worker in oci_core_instance.kube_server_workers : {
      ocid                = worker.id
      display_name        = worker.display_name
      shape               = worker.shape
      availability_domain = worker.availability_domain
      public_ip           = worker.public_ip
      private_ip          = worker.private_ip
      state               = worker.state
      time_created        = worker.time_created
    }
  ]
}
