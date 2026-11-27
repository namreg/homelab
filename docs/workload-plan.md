---
type: Plan
title: Workload plan
description: Target placement, initial resource limits, and recovery sources for Proxmox guests.
---

# Workload plan

## Guest allocation

These are target values. Reuse VM 100, currently `lab-01`, as `dev-01`.
See the [automation plan](automation.md) for the current VM configuration.

| Guest | Type | Purpose | vCPU | RAM (GiB) | Disk (GiB) |
| --- | --- | --- | ---: | ---: | ---: |
| `git-01` | Unprivileged LXC | Forgejo with SQLite | 1 | 1 | 8 |
| `apps-01` | Ubuntu VM | Home services with Docker Compose and Dockhand | 4 | 4 | 96 |
| `k3s-01` | Ubuntu VM | Single-node k3s for personal projects | 2 | 3 | 40 |
| `dev-01` | Ubuntu VM | Two or three concurrent Codex agents, controlled from the MacBook | 4 | 6 | 64 |
| Total | | | 11 | 14 | 208 |

Paperless, Mealie, Homepage, and BookOrbit are examples of services for `apps-01`.
Keep their Compose files in this repository. Use Dockhand to manage the services.

## Capacity

Use `local-lvm` for all four guest disks. Check the free space in the pool,
not just the NVMe capacity in the [equipment inventory](equipment.md).
Leave the remaining RAM for Proxmox and unallocated capacity. Check memory use
on the host and guests during Paperless OCR and concurrent builds on `dev-01`
before increasing guest limits.

## Recovery

Use this repository on GitHub to recover Compose files and infrastructure
configuration. Recover secrets from 1Password. Keep encrypted backups of
application data in Backblaze B2, including Forgejo repositories, its database
and attachments, and the Paperless document export.
