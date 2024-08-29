terraform {
  required_providers {
    civo = {
      source = "civo/civo"
    }
  }
}

variable "region" {}
variable "network" {}
variable "firewall" {}
variable "ssh" {}
variable "token"{}

provider "civo" {
  region = var.region
  token  = var.token
}

data "civo_disk_image" "ubuntu" {
  filter {
    key    = "name"
    values = ["ubuntu-jammy"] #hard to figure out, used https://www.civo.com/api/disk-images
  }
}

resource "civo_instance" "main" {
  region      = var.region
  hostname    = "main"
  tags        = ["kubernetes"]
  notes       = "main kubernetes cluster"
  firewall_id = var.firewall
  network_id  = var.network
  sshkey_id   = var.ssh
  size       = "g4s.medium"
  disk_image = data.civo_disk_image.ubuntu.diskimages[0].id
}

resource "civo_instance" "node1" {
  region      = var.region
  hostname    = "node1"
  tags        = ["kubernetes"]
  notes       = "node1"
  firewall_id = var.firewall
  network_id  = var.network
  sshkey_id   = var.ssh
  size       = "g4s.medium"
  disk_image = data.civo_disk_image.ubuntu.diskimages[0].id
}

resource "civo_instance" "node2" {
  region      = var.region
  hostname    = "node2"
  tags        = ["kubernetes"]
  notes       = "node2"
  firewall_id = var.firewall
  network_id  = var.network
  sshkey_id   = var.ssh
  size       = "g4s.medium"
  disk_image = data.civo_disk_image.ubuntu.diskimages[0].id
}

locals {
  inventory = <<-EOT
    groups:
      control:
        - {host: "${civo_instance.main.public_ip}"}
      nodes:
        - {host: "${civo_instance.node1.public_ip}"}
        - {host: "${civo_instance.node2.public_ip}"}
  EOT
  env= <<-EOT
    vars:
      DEBIAN_FRONTEND: noninteractive
      MAIN_IP: ${civo_instance.main.public_ip}
      NODE1_IP: ${civo_instance.node1.public_ip}
      NODE2_IP: ${civo_instance.node2.public_ip}
      MAIN_PRIVATE_IP: ${civo_instance.main.private_ip}
      NODE1_PRIVATE_IP: ${civo_instance.node1.private_ip}
      NODE2_PRIVATE_IP: ${civo_instance.node2.private_ip}
  EOT
}

resource "local_file" "inventory" {
  filename = "inventory.yml"
  content  = local.inventory
}

resource "local_file" "env" {
  filename = "env.yml"
  content  = local.env
}

output "main_ip" {
  value = civo_instance.main.public_ip
}

output "node1_ip" {
  value = civo_instance.node1.public_ip
}

output "node2_ip" {
  value = civo_instance.node2.public_ip
}