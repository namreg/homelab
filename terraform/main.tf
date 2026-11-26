terraform {
  required_version = "~> 1.17.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.124.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.1.250:8006/"
  insecure = false
}

data "proxmox_virtual_environment_node" "host" {
  node_name = "pve"
}

output "host_cpu_model" {
  value = data.proxmox_virtual_environment_node.host.cpu_model
}
