#!/bin/sh
## setup command=wget https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openbh/restore-settings.sh -O - | /bin/sh
##################################
cd /tmp || exit 1
if wget -q "https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openbh/settings_backup_OpenBH.tar.gz"; then
    echo "Download completed successfully"
else
    echo "Download failed"
    exit 1
fi
sleep 2
if [ -f "settings_backup_OpenBH.tar.gz" ]; then
    tar -xzf settings_backup_OpenBH.tar.gz -C /
    rm -f settings_backup_OpenBH.tar.gz
else
    echo "Backup file not found"
    exit 1
fi
sleep 5
rm -rf /var/cache/opkg/* 2>/dev/null
rm -rf /var/lib/opkg/lists/* 2>/dev/null
rm -f /run/opkg.lock 2>/dev/null
sleep 5
echo "Process completed successfully"
sleep 5
exit 0
