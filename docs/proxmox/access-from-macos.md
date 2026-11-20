---
type: Runbook
title: Proxmox access from macOS
description: Access the Proxmox web interface from the MacBook with Mullvad connected.
---

# Proxmox access from macOS

The [MacBook](../equipment.md) connects to Keenetic over Wi-Fi. The Proxmox host
connects to the upstream router by Ethernet. Without a host route, the MacBook
sends traffic for Proxmox through the VPN instead of Keenetic.

1. Connect to the home Wi-Fi network. In Mullvad, enable **Local network sharing**.

2. Check the saved routes on the Mac:

   ```sh
   networksetup -getadditionalroutes "Wi-Fi"
   ```

3. If the output includes `192.168.1.250 255.255.255.255 192.168.2.1`, skip
   to step 4. If there are no saved routes, run:

   ```sh
   sudo networksetup -setadditionalroutes "Wi-Fi" \
     192.168.1.250 255.255.255.255 192.168.2.1
   ```

   If other routes exist, include their destination, mask, and gateway in the
   same command. This command replaces the full list. macOS keeps the route
   after a restart. It applies to the Wi-Fi service, not just the home network.

4. With Mullvad connected, open <https://192.168.1.250:8006>. The Proxmox
   login page confirms access. If it does not open, run
   `route -n get 192.168.1.250`. Check that the gateway is `192.168.2.1`
   and the interface is Wi-Fi, not a VPN tunnel.
