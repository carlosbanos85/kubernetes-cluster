locals {
  master_hostname = "${var.project_name}-master"

  k3s_disable_flags = join(" ", [for component in var.k3s_disable_flags : "--disable ${component}"])
}
