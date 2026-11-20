---
type: Plan
title: Automation plan
description: How to create and configure Linux virtual machines on Proxmox VE.
---

# Automation plan

Resume at the first unchecked task. Mark a task complete after you verify it.

## Prepare the host

- [x] Install Proxmox VE on the [HP ProDesk](equipment.md).
- [x] Open the [web interface from the MacBook](proxmox/access-from-macos.md).

## Prepare Terraform access and storage

- [ ] Create `terraform@pve` under **Datacenter > Permissions > Users**.
  Select the `pve` realm.
- [ ] Create an API token for this user. Grant the user and token only the
  permissions needed to download images and manage the planned VMs.
- [ ] Configure the `bpg/proxmox` Terraform provider and verify API access
  with the token instead of the `root` password.
- [ ] Enable the `Import` content type on `local` for source images.

## Create the VMs

- [ ] Select an official Ubuntu `amd64` cloud image. Pin its build URL and
  SHA-256 checksum. Define one Terraform download resource per host.
- [ ] Define each VM's name, CPU, memory, disk size, and network bridge.
  Use `disk.import_from` to create each VM disk on `local-lvm` from the
  shared image. No VM template is needed. See the [provider guide][image].
- [ ] Set the initial user, public SSH key, and network settings in the
  `initialization` block. Proxmox passes these settings to cloud-init.
- [ ] Review the Terraform plan and apply it. After cloud-init finishes,
  connect to each guest over SSH with the configured key.

## Configure guest services

- [ ] Use Ansible to install packages and configure services. Keep service
  configuration in Ansible so changes do not require a new VM.
- [ ] Verify the services and run the playbook again. Confirm that the second
  run makes no changes.

Keep HCL, cloud-init templates, and Ansible playbooks outside the documentation
bundle. Keep private keys, API tokens, and state files out of Git.

[image]: https://bpg.sh/docs/guides/cloud-image/
