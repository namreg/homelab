---
type: Plan
title: Automation plan
description: Tools and responsibilities for the first virtual machine.
---

# Automation plan

The [equipment inventory](equipment.md) lists the physical host. The steps
below describe the plan, not an installed system.

1. Install Proxmox VE on the host. Prepare a VM template from a guest image
   that supports cloud-init. See [Cloud-Init Support in Proxmox VE][pve].
2. Use either OpenTofu or Terraform to create a VM from the template through
   the Proxmox API. Define the VM's CPU, memory, disks, and network interface
   in HCL. Choose one tool to manage the VM and its state.
3. Use cloud-init to set up the guest on first boot. Give it the initial user,
   SSH public key, and network settings needed for Ansible to connect.
4. After cloud-init finishes, use Ansible to install packages, configure
   services, and maintain the guest. Keep ongoing service configuration in
   Ansible so that a change does not require a new VM.

Keep HCL, cloud-init templates, and Ansible playbooks outside the documentation
bundle. Keep private keys, API tokens, and state files out of Git.

[pve]: https://pve.proxmox.com/wiki/Cloud-Init_Support
