#!/bin/sh
cd /tmp || exit 1
if wget -q "https://github.com/emilnabil/backup-images/raw/refs/heads/main/Backup-OpenSpa/settings_backup_OpenSPA.tar.gz"; then
    echo "Download completed successfully"
else
    echo "Download failed"
    exit 1
fi
sleep 2
if [ -f "settings_backup_OpenSPA.tar.gz" ]; then
    tar -xzf settings_backup_OpenSPA.tar.gz -C /
    rm -f settings_backup_OpenSPA.tar.gz
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
killall -9 enigma2 
exit 0
