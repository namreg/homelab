---
type: Plan
title: Automation plan
description: How to create and configure Linux virtual machines on Proxmox VE.
---

# Automation plan

The [equipment inventory](equipment.md) lists the physical host. The steps
below describe the plan, not an installed system.

1. Install Proxmox VE. Enable the `Import` content type on `local` for the
   source image. Use `local-lvm` for VM disks.
2. Use Terraform with the `bpg/proxmox` provider. Select an official Ubuntu
   `amd64` cloud image. Record its build URL and SHA-256 checksum in the
   configuration. Download the image once per host. For each VM, set the
   name, CPU, memory, disk size, and network bridge. Use `disk.import_from`
   to create a separate disk from the shared image. No VM template is needed.
   See the [provider guide][image].
3. Set the initial user, SSH public key, and network settings in the Terraform
   `initialization` block. Proxmox supplies these settings to the guest on a
   cloud-init drive. On first boot, cloud-init applies them inside the guest.
4. After cloud-init finishes, use Ansible to install packages, configure
   services, and maintain the guest. Keep ongoing service configuration in
   Ansible so that a change does not require a new VM.

Keep HCL, cloud-init templates, and Ansible playbooks outside the documentation
bundle. Keep private keys, API tokens, and state files out of Git.

[image]: https://bpg.sh/docs/guides/cloud-image/
