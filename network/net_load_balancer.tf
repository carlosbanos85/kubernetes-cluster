# Network Load Balancer for Gateway API
resource "oci_network_load_balancer_network_load_balancer" "kube_server_nlb" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-gateway-nlb"
  subnet_id      = oci_core_subnet.lb_subnet.id

  is_private                     = false
  is_preserve_source_destination = true

  freeform_tags = merge(var.common_tags, {
    Component = "network"
    Type      = "load-balancer"
    Purpose   = "gateway-api"
  })
}

# Backend Set for Gateway HTTP
resource "oci_network_load_balancer_backend_set" "gateway_http_backend_set" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.kube_server_nlb.id
  name                     = "gateway-http-backend-set"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol           = "HTTP"
    port               = 30080
    url_path           = "/healthz"
    return_code        = 200
    timeout_in_millis  = 3000
    interval_in_millis = 10000
    retries            = 3
  }

  is_preserve_source = true
}

# Backend Set for Gateway HTTPS
resource "oci_network_load_balancer_backend_set" "gateway_https_backend_set" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.kube_server_nlb.id
  name                     = "gateway-https-backend-set"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol = "TCP"
    port     = 30443
  }

  is_preserve_source = true
}

# HTTP Listener
resource "oci_network_load_balancer_listener" "gateway_http_listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.kube_server_nlb.id
  name                     = "gateway-http-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.gateway_http_backend_set.name
  port                     = 80
  protocol                 = "TCP"
}

# HTTPS Listener
resource "oci_network_load_balancer_listener" "gateway_https_listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.kube_server_nlb.id
  name                     = "gateway-https-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.gateway_https_backend_set.name
  port                     = 443
  protocol                 = "TCP"
}
