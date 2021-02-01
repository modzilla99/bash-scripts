# Dynamic DNS @hetzner with OPNsense

This script automatically updates your dns records with the IP-Address set on the PPPoE interface.

It can be added as a cron job within opnsense by copying the file `actions_dnsupdate.conf` to 
`/usr/local/opnsense/service/conf/actions.d/actions_dnsupdate.conf`.

Restarting configd and the webgui should add a new option in `System/Settings/Cron` "New job" called "hetzner dns update"
```bash
service configd restart
/usr/local/etc/rc.restart_webgui
```
`update-dns-records` has to be copied to `/usr/local/bin/update-dns-records`
