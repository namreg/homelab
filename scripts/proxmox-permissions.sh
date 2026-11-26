#!/bin/sh
set -eu

role=TerraformProvisioner
privileges='Datastore.Audit Datastore.AllocateTemplate Sys.AccessNetwork Sys.Audit'

if pvesh get "/access/roles/$role" >/dev/null 2>&1; then
    pveum role modify "$role" --privs "$privileges"
else
    pveum role add "$role" --privs "$privileges"
fi

for path in /storage/local /nodes/pve; do
    pveum acl modify "$path" --roles "$role" --users terraform@pve --tokens 'terraform@pve!homelab' --propagate 0
done

pveum user token permissions terraform@pve homelab
