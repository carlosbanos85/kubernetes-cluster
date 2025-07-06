variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "availability_domain" {
  description = "(Optional) Default Availability Domain"
  type        = string
  default     = ""
}

variable "instance_image_id" {
  description = "OCID of the instance image"
  type        = string
}

# Compute Configuration
variable "instance_shape" {
  description = "Shape of the compute instances"
  type        = string
}

variable "instance_ocpus" {
  description = "Number of OCPUs per instance"
  type        = number
}

variable "instance_memory_gb" {
  description = "Memory in GB per instance"
  type        = number
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GB"
  type        = number
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
}

# Network Configuration
variable "subnet_id" {
  description = "OCID of the subnet where instances will be created"
  type        = string
}

variable "network_security_group_id" {
  description = "OCID of the Network Security Group"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block of the VCN"
  type        = string
}

variable "k3s_disable_flags" {
  description = "List of k3s components to disable"
  type        = list(string)
}

variable "cluster_domain" {
  description = "Cluster domain suffix"
  type        = string
}

variable "master_hostname" {
  description = "Hostname for the master node"
  type        = string
}

variable "worker_hostname" {
  description = "Hostname for the worker nodes"
  type        = string
}

# Common Configuration
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}
