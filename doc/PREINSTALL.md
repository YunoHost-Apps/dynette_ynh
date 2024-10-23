This app requires patching your server. Indeed, YunoHost is configured to conflict with bind9.

```
sed -i 's|Package: bind9|Package: _bind9|' /etc/apt/preferences.d/ban_packages
sed -i 's|Conflicts: apache2, bind9,|Conflicts: apache2,|' /var/lib/dpkg/status
```
