#!/bin/sh
set -eu

role=TerraformProvisioner
privileges='Datastore.Audit Datastore.AllocateTemplate Sys.AccessNetwork Sys.Audit'
privileges="$privileges Datastore.AllocateSpace SDN.Use VM.Allocate VM.Audit VM.PowerMgmt"
privileges="$privileges VM.Config.CPU VM.Config.Memory VM.Config.Disk VM.Config.Network"
privileges="$privileges VM.Config.Cloudinit VM.Config.CDROM VM.Config.Options VM.Config.HWType"

if pvesh get "/access/roles/$role" >/dev/null 2>&1; then
    pveum role modify "$role" --privs "$privileges"
else
    pveum role add "$role" --privs "$privileges"
fi

for path in /storage/local /storage/local-lvm /nodes/pve /vms/100 /sdn/zones/localnetwork/vmbr0; do
    pveum acl modify "$path" --roles "$role" --users terraform@pve --tokens 'terraform@pve!homelab' --propagate 0
done

pveum user token permissions terraform@pve homelab
