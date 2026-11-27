resource "proxmox_virtual_environment_vm" "lab_01" {
  name      = "lab-01"
  node_name = data.proxmox_virtual_environment_node.host.node_name
  vm_id     = 100

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    import_from  = proxmox_download_file.ubuntu_noble.id
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = "local-lvm"

    ip_config {
      ipv4 {
        address = var.guest_ipv4_address
        gateway = var.ipv4_gateway
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [trimspace(file("${path.module}/lab-01.pub"))]
    }
  }
}
