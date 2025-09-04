variable "compartment_id" {
  description = "OCID of the compartment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "api_subnet_cidr" {
  description = "CIDR block for the API subnet"
  type        = string
}

variable "worker_subnet_cidr" {
  description = "CIDR block for the worker subnet"
  type        = string
}

variable "bgp_announced_cidr" {
  description = "CIDR block for BGP announced IPs"
  type        = string
}
