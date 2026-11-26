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

## Prepare OpenTofu access and storage

- [x] Create `terraform@pve` in the `pve` realm.
- [x] Create the `homelab` token for `terraform@pve` with privilege separation.
- [x] Grant node read access and image download access with one role.
  From the repository root on the Mac, run
  `mise run pve:permissions`. This task connects to the host as `root` over SSH.
  Check for `Sys.Audit` and `Sys.AccessNetwork` on `/nodes/pve` and
  `Datastore.AllocateTemplate` on `/storage/local`. The script assigns
  `TerraformProvisioner` to the user and the token.
  Use this role only for OpenTofu. Run the script again after a host rebuild
  once the user and token exist.
- [x] Run the [OpenTofu access check](#check-opentofu-access-from-macos)
  after the role change.
- [ ] Grant VM permissions after selecting the VM and disk allocation paths.
- [x] Verify that `local` accepts the `import` content type for source images.

## Create the VMs

- [x] Download the Ubuntu Server 24.04 LTS `amd64` cloud image to `local`.
  OpenTofu pins build `20261017` and its SHA-256 checksum.
- [ ] Define each VM's name, CPU, memory, disk size, and network bridge.
  Use `disk.import_from` to create each VM disk on `local-lvm` from the
  shared image. No VM template is needed. See the [provider guide][image].
- [ ] Set the initial user, public SSH key, and network settings in the
  `initialization` block. Proxmox passes these settings to cloud-init.
- [ ] Review the OpenTofu plan and apply it. After cloud-init finishes,
  connect to each guest over SSH with the configured key.

## Configure guest services

- [ ] Use Ansible to install packages and configure services. Keep service
  configuration in Ansible so changes do not require a new VM.
- [ ] Verify the services and run the playbook again. Confirm that the second
  run makes no changes.

Keep HCL, cloud-init templates, and Ansible playbooks outside the documentation
bundle. Keep private keys, API tokens, and unencrypted state out of Git.

## Check OpenTofu access from macOS

After cloning the repository, run `mise bootstrap` at its root to install
the tools and initialize OpenTofu. Run it again if you remove
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
OpenTofu needs in this Environment.

Run the plan with the 1Password CLI installed by `mise bootstrap`:

```sh
mise run tf:plan
```

After the image download, the plan should report no changes. Commit and push
the encrypted `terraform/terraform.tfstate` after each operation that changes
it. Pull the latest state before using another workstation. Run OpenTofu on
only one workstation at a time. Git does not lock state across workstations.
OpenTofu encrypts state and saved plans. The tasks load the passphrase from
the `Homelab OpenTofu state` item in the `Personal` 1Password vault. Recover
the same item before restoring state. Do not replace its password without
migrating the encrypted state.

[image]: https://bpg.sh/docs/guides/cloud-image/
