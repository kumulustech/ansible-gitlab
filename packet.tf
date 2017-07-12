# Create a multi-node openstack system in Packet.net

# export PACKET_AUTH_TOKEN=GET_PACKET_AUTH_TOKEN_FROM_API_PAGES

variable domain_name {
    type = "string"
    default = "kumulus.co"
}

variable control_name {
    type = "string"
    default = "gitlab"
}

variable project_id {
    type = "string"
    default =  "b972930e-5e5a-4112-ae35-c1776bf0b65c"
}

resource "packet_device" "control" {
        hostname = "${var.control_name}"
        plan = "baremetal_0"
        facility = "ewr1"
        operating_system = "ubuntu_16_04_image"
        billing_cycle = "hourly"
        project_id = "${var.project_id}"
        provisioner "local-exec" {
          command = "sed -i '' -e 's/${var.control_name}.*/${var.control_name} ansible_ssh_host=${packet_device.control.network.0.address}/' inventory"
        }
}

# Create a new block volume
resource "packet_volume" "control_vol" {
    description = "${var.control_name}_vol"
    facility = "ewr1"
    project_id = "${var.project_id}"
    plan = "storage_1"
    size = 50
    billing_cycle = "hourly"
}

resource "dnsimple_record" "control" {
    domain = "${var.domain_name}"
    type = "A"
    name = "${var.control_name}"
    value = "${packet_device.control.network.0.address}"
}

