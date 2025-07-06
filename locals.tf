locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Terraform   = "true"
    CreatedBy   = "terraform"
    ManagedBy   = "kube-server-oci-terraform"
  }

  # Availability Domain
  ## Using provided value in tf variables or default to first available
  availability_domain = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name

  # Instance Image
  ## Retrieve the latest Oracle Linux 9 image and use the latest one.
  instance_image = data.oci_core_images.ol9_images.images[0].id

  # VCN & Subnet DNS Label
  ## Leverage Project Name to create a unique DNS label for VCN and Subnet
  vcn_dns_label    = replace(var.project_name, "-", "")
  subnet_dns_label = "${local.vcn_dns_label}-subnet"
}
