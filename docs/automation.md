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

- [x] Create `terraform@pve` in the `pve` realm.
- [x] Create the `homelab` token. Give the user and token the `PVEAuditor`
  role on `/nodes/pve`. Verify node access with an authenticated HTTPS request.
- [ ] Run the [Terraform access check](#check-terraform-access-from-macos).
- [ ] Grant the user and token the additional rights needed to download images
  and manage the planned VMs.
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

## Check Terraform access from macOS

After cloning the repository, run `mise bootstrap` at its root to install
the tools and initialize Terraform. Run it again if you remove
`terraform/.terraform/`. For access to the host, use the home network route
from the [access instructions](proxmox/access-from-macos.md).

On each new Mac, copy `/etc/pve/pve-root-ca.pem` from the host over SSH.
Check the SSH host key against the fingerprint on the host console first.
Save the certificate as `~/pve-root-ca.pem`. Add it to the login keychain
for TLS connections to this host:

```sh
security add-trusted-cert -r trustRoot -p ssl -s 192.168.1.250 \
  -k "$HOME/Library/Keychains/login.keychain-db" "$HOME/pve-root-ca.pem"
```

In the 1Password desktop app, open **Settings > Developer**. Enable CLI
integration. In the `homelab` Environment, set `PROXMOX_VE_API_TOKEN`
to the full token: `terraform@pve!homelab=` followed by the token secret.
The task selects this Environment by ID. Keep only the secrets that
Terraform needs in this Environment.

Run the plan with the 1Password CLI installed by `mise bootstrap`:

```sh
mise run tf:plan
```

Check that the plan shows `host_cpu_model` and no resource changes. Do not
run `apply` for this check. On a new workstation, use the same configuration
and provider lock file. No state backup is needed for this read-only check.
Before managing VMs, set up a backup for Terraform state outside Git.

[image]: https://bpg.sh/docs/guides/cloud-image/
