variable "state_passphrase" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.state_passphrase) >= 32 && !startswith(var.state_passphrase, "op://")
    error_message = "Load the state passphrase from 1Password with op run."
  }
}

terraform {
  required_version = "~> 1.13.0"

  required_providers {
    proxmox = {
      source  = "registry.terraform.io/bpg/proxmox"
      version = "0.124.0"
    }
  }

  encryption {
    key_provider "pbkdf2" "homelab" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "homelab" {
      keys = key_provider.pbkdf2.homelab
    }

    state {
      method   = method.aes_gcm.homelab
      enforced = true
    }

    plan {
      method   = method.aes_gcm.homelab
      enforced = true
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  insecure = false
}

data "proxmox_virtual_environment_node" "host" {
  node_name = "pve"
}

output "host_cpu_model" {
  value = data.proxmox_virtual_environment_node.host.cpu_model
}

locals {
  ubuntu_image = {
    release = "24.04"
    build   = "20261017"
    sha256  = "04e8f2461a16a44e78a370284471f29616cdd9baf1893df25807b71f985b6c94"
  }
}

resource "proxmox_download_file" "ubuntu_noble" {
  node_name           = data.proxmox_virtual_environment_node.host.node_name
  datastore_id        = "local"
  content_type        = "import"
  file_name           = "ubuntu-${local.ubuntu_image.release}-server-cloudimg-amd64-${local.ubuntu_image.build}.qcow2"
  url                 = "https://cloud-images.ubuntu.com/releases/${local.ubuntu_image.release}/release-${local.ubuntu_image.build}/ubuntu-${local.ubuntu_image.release}-server-cloudimg-amd64.img"
  checksum_algorithm  = "sha256"
  checksum            = local.ubuntu_image.sha256
  overwrite_unmanaged = false
}
