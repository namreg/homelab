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
- [x] Grant access to VM 100, `local-lvm`, and the `vmbr0` bridge.
- [x] Verify that `local` accepts the `import` content type for source images.

## Create the VMs

- [x] Download the Ubuntu Server 24.04 LTS `amd64` cloud image to `local`.
  OpenTofu pins build `20261017` and its SHA-256 checksum.
- [x] Define `lab-01` with two CPU cores, 2048 MiB of RAM, and a 20 GiB disk.
  Use `disk.import_from` to create each VM disk on `local-lvm` from the
  shared image. No VM template is needed. See the [provider guide][image].
- [x] Set the initial user, public SSH key, and network settings in the
  `initialization` block. Proxmox passes these settings to cloud-init.
- [x] Review the OpenTofu plan and apply it. After cloud-init finishes,
  connect to each guest over SSH with the configured key.

Set the Proxmox endpoint, guest IPv4 address with prefix length, and gateway
in `terraform/terraform.tfvars`. This file contains non-secret site settings.
Input types and validation rules are in `terraform/variables.tf`.
Keep credentials and the state passphrase in 1Password.

The `ubuntu_image` local in `terraform/main.tf` pins the release, build, and
SHA-256 checksum. Update these values together when you select a new image.
Review `mise run tf:plan` before applying changes, especially disk changes.
Run `mise run check` to check OpenTofu formatting and configuration, along
with the other repository checks. To check only OpenTofu, run
`mise run lint:terraform`. Initialize the working directory with
`mise bootstrap` before the first check.

Task definitions are grouped in `mise-tasks/lint.toml`,
`mise-tasks/terraform.toml`, and `mise-tasks/proxmox.toml`. The root
`mise.toml` sets tool versions, shared environment variables, task file paths,
and the `check` task.

The guest uses `192.168.1.251/24` with gateway `192.168.1.1`. Keep this
address outside the DHCP pool. Connect directly from the repository root on
the Mac with the 1Password SSH agent:

```sh
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
ssh -F /dev/null -o IdentitiesOnly=yes -i terraform/lab-01.pub \
  -o HostKeyAlias=lab-01-via-pve ubuntu@192.168.1.251
```

`HostKeyAlias` reuses the verified guest host key. It does not route traffic
through Proxmox. Use the `homelab-lab-01` key to log in to Ubuntu.
If you replace the VM, verify its new SSH host key before connecting.

## Configure guest services

- [ ] Use Ansible to install packages and configure services. Keep service
  configuration in Ansible so changes do not require a new VM.
- [ ] Verify the services and run the playbook again. Confirm that the second
  run makes no changes.

Keep HCL, cloud-init templates, and Ansible playbooks outside the documentation
bundle. Keep private keys, API tokens, and unencrypted state out of Git.

## Check OpenTofu access from macOS

On a new Mac, sign in to the 1Password desktop app. Under **Settings >
Developer**, enable CLI integration and the SSH agent. Check that you can
open `Homelab OpenTofu state` in the `Homelab` vault. Enable this vault
in `~/.config/1Password/ssh/agent.toml` for SSH access.

At the repository root, run `mise bootstrap` to install the tools and
initialize OpenTofu. Run it again if you remove `terraform/.terraform/`.
For access to Proxmox, follow the [network instructions](proxmox/access-from-macos.md).

On each new Mac, copy `/etc/pve/pve-root-ca.pem` from the host over SSH.
Check the SSH host key against the fingerprint on the host console first.
Save the certificate as `~/pve-root-ca.pem`. Add it to the login keychain
for TLS connections to this host:

```sh
security add-trusted-cert -r trustRoot -p ssl -s 192.168.1.250 \
  -k "$HOME/Library/Keychains/login.keychain-db" "$HOME/pve-root-ca.pem"
```

The plan reads `PROXMOX_VE_API_TOKEN` from the existing `homelab`
1Password Environment. Use the same Environment on the new Mac.
Do not create a new token or state passphrase.

Run the plan with the 1Password CLI installed by `mise bootstrap`:

```sh
mise run tf:plan
```

To apply changes, run:

```sh
mise run tf:apply
```

Review the plan. Enter `yes` to apply it.

After the image download, the plan should report no changes. Commit and push
the encrypted `terraform/terraform.tfstate` after each operation that changes
it. Pull the latest state before using another workstation. Run OpenTofu on
only one workstation at a time. Git does not lock state across workstations.
OpenTofu encrypts state and saved plans. The tasks load the passphrase from
the `Homelab OpenTofu state` item in the `Homelab` 1Password vault. Recover
the same item before restoring state. Do not replace its password without
migrating the encrypted state.

[image]: https://bpg.sh/docs/guides/cloud-image/
