# OCI
variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}
variable "region" {
  description = "Region"
  type        = string
}

# Project Config
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "availability_domain" {
  description = "(Optional) Default Availability Domain"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (staging, production)"
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be one of: staging, production."
  }
}

# Network Configuration
variable "vcn_cidr" {
  description = "CIDR block for the Virtual Cloud Network"
  type        = string
  validation {
    condition     = can(cidrhost(var.vcn_cidr, 0))
    error_message = "VCN CIDR must be a valid IPv4 CIDR block."
  }
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR block."
  }
}

# Compute Configuration
variable "instance_shape" {
  description = "Shape of the compute instances"
  type        = string
  # validation {
  #   condition     = contains(["VM.Standard.A1.Flex"], var.instance_shape)
  #   error_message = "Instance shape must be VM.Standard.A1.Flex."
  # }
}

variable "instance_ocpus" {
  description = "Number of OCPUs per instance"
  type        = number
  validation {
    condition     = var.instance_ocpus >= 1 && var.instance_ocpus <= 4
    error_message = "OCPUs must be between 1 and 4 for free tier compatibility."
  }
}

variable "instance_memory_gb" {
  description = "Memory in GB per instance"
  type        = number
  validation {
    condition     = var.instance_memory_gb >= 1 && var.instance_memory_gb <= 8
    error_message = "Memory must be between 1 and 8 GB per instance for free tier."
  }
}

variable "boot_volume_size_gb" {
  description = "Boot volume size in GB"
  type        = number
  validation {
    condition     = var.boot_volume_size_gb >= 50 && var.boot_volume_size_gb <= 200
    error_message = "Boot volume size must be between 50 and 200 GB."
  }
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 3
    error_message = "Worker count must be between 1 and 3 for free tier optimization."
  }
}

# K3s Configuration
variable "k3s_disable_flags" {
  description = "List of K3s components to disable on startup"
  type        = list(string)
  validation {
    condition = alltrue([
      for component in var.k3s_disable_flags :
      contains(["traefik", "servicelb", "metrics-server", "local-storage"], component)
    ])
    error_message = "Only traefik, servicelb, metrics-server, and local-storage can be disabled."
  }
}

variable "cluster_domain" {
  description = "Cluster domain suffix for internal DNS"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9.-]+$", var.cluster_domain))
    error_message = "Cluster domain must be a valid domain name."
  }
}

variable "master_hostname" {
  description = "Hostname for the master node"
  type        = string
}

variable "worker_hostname" {
  description = "Hostname for the worker nodes"
  type        = string
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key content for instance access"
  type        = string
  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521)", var.ssh_public_key))
    error_message = "SSH public key must be in valid format (ssh-rsa, ssh-ed25519, or ecdsa)."
  }
}
