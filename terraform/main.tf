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

resource "proxmox_download_file" "ubuntu_noble" {
  node_name           = data.proxmox_virtual_environment_node.host.node_name
  datastore_id        = "local"
  content_type        = "import"
  file_name           = "ubuntu-24.04-server-cloudimg-amd64-20261017.qcow2"
  url                 = "https://cloud-images.ubuntu.com/releases/24.04/release-20261017/ubuntu-24.04-server-cloudimg-amd64.img"
  checksum_algorithm  = "sha256"
  checksum            = "04e8f2461a16a44e78a370284471f29616cdd9baf1893df25807b71f985b6c94"
  overwrite_unmanaged = false
}
