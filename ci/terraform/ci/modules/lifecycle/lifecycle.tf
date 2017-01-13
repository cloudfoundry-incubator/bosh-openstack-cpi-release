variable "dns_nameservers" {
  description = "DNS server IPs"
}

variable "region_name" {
  description = "OpenStack region name"
}

variable "default_router_id" {}

variable "ext_net_name" {
  description = "OpenStack external network name to register floating IP"
}

output "lifecycle_openstack_net_id" {
  value = "${openstack_networking_network_v2.lifecycle_net.id}"
}

output "lifecycle_manual_ip" {
  value = "${cidrhost(openstack_networking_subnet_v2.lifecycle_subnet.cidr, 3)}"
}

output "lifecycle_net_id_no_dhcp_1" {
  value = "${openstack_networking_network_v2.lifecycle_net_no_dhcp_1.id}"
}

output "lifecycle_no_dhcp_manual_ip_1" {
  value = "${cidrhost(openstack_networking_subnet_v2.lifecycle_subnet_no_dhcp_1.cidr, 3)}"
}

output "lifecycle_net_id_no_dhcp_2" {
  value = "${openstack_networking_network_v2.lifecycle_net_no_dhcp_2.id}"
}

output "lifecycle_no_dhcp_manual_ip_2" {
  value = "${cidrhost(openstack_networking_subnet_v2.lifecycle_subnet_no_dhcp_2.cidr, 3)}"
}

output "lifecycle_floating_ip" {
  value = "${openstack_networking_floatingip_v2.lifecycle_floating_ip.address}"
}

resource "openstack_networking_network_v2" "lifecycle_net" {
  region         = "${var.region_name}"
  name           = "lifecycle"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "lifecycle_subnet" {
  region           = "${var.region_name}"
  network_id       = "${openstack_networking_network_v2.lifecycle_net.id}"
  cidr             = "10.0.1.0/24"
  ip_version       = 4
  name             = "lifecycle_sub"
  allocation_pools = {
    start = "10.0.1.200"
    end   = "10.0.1.254"
  }
  gateway_ip       = "10.0.1.1"
  enable_dhcp      = "true"
  dns_nameservers = ["${compact(split(",",var.dns_nameservers))}"]
}

resource "openstack_networking_network_v2" "lifecycle_net_no_dhcp_1" {
  region         = "${var.region_name}"
  name           = "lifecycle-no-dhcp-1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "lifecycle_subnet_no_dhcp_1" {
  region           = "${var.region_name}"
  network_id       = "${openstack_networking_network_v2.lifecycle_net_no_dhcp_1.id}"
  cidr             = "10.1.1.0/24"
  ip_version       = 4
  name             = "lifecycle-subnet-no-dhcp-1"
  gateway_ip       = "10.1.1.1"
  enable_dhcp      = "false"
  dns_nameservers = ["${compact(split(",",var.dns_nameservers))}"]
}

resource "openstack_networking_network_v2" "lifecycle_net_no_dhcp_2" {
  region         = "${var.region_name}"
  name           = "lifecycle-no-dhcp-2"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "lifecycle_subnet_no_dhcp_2" {
  region           = "${var.region_name}"
  network_id       = "${openstack_networking_network_v2.lifecycle_net_no_dhcp_2.id}"
  cidr             = "10.2.1.0/24"
  ip_version       = 4
  name             = "lifecycle-subnet-no-dhcp-2"
  gateway_ip       = "10.2.1.1"
  enable_dhcp      = "false"
  dns_nameservers = ["${compact(split(",",var.dns_nameservers))}"]
}

# router

resource "openstack_networking_router_interface_v2" "lifecycle_port" {
  region    = "${var.region_name}"
  router_id = "${var.default_router_id}"
  subnet_id = "${openstack_networking_subnet_v2.lifecycle_subnet.id}"
}

resource "openstack_networking_floatingip_v2" "lifecycle_floating_ip" {
  region = "${var.region_name}"
  pool   = "${var.ext_net_name}"
}
