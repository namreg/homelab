---
type: Runbook
title: Stop the idle whine on the HP ProDesk
description: Disable audio power saving on the Proxmox host to stop the noise at idle.
---

# Stop the idle whine on the HP ProDesk

On the [HP ProDesk](../equipment.md), muting the Realtek ALC897 speaker output
had no effect. The noise stopped when the `snd_hda_intel` power saving delay
changed from `1` to `0`. It returned when the delay changed back to `1`.
This test did not identify the physical source of the noise.

## Apply the setting

In the [Proxmox host shell](access-from-macos.md), run as `root`:

```sh
echo 0 > /sys/module/snd_hda_intel/parameters/power_save
```

Listen for the noise at idle. To keep the setting after a restart, run:

```sh
printf '%s\n' 'options snd_hda_intel power_save=0' \
  > /etc/modprobe.d/hda-power-save.conf
update-initramfs -u -k all
```

No immediate restart is necessary. After the next restart, run:

```sh
cat /sys/module/snd_hda_intel/parameters/power_save
```

Confirm that the value is `0` and the noise does not return at idle.

## Restore the previous setting

```sh
rm /etc/modprobe.d/hda-power-save.conf
update-initramfs -u -k all
echo 1 > /sys/module/snd_hda_intel/parameters/power_save
```
