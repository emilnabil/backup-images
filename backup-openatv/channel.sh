#!/bin/sh
# Command:
# wget https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv/channel.sh -qO - | /bin/sh
###########################################
MY_URL="https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv"
echo "******************************************************************************************************************"
echo "        DOWNLOAD AND INSTALL CHANNEL"
echo "=================================================================================================================="
if [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OSTYPE='Opensource'
    OPKG='opkg update'
    OPKGINSTAL='opkg install'
fi
echo "        REMOVE OLD CHANNELS..."
rm -rf /etc/enigma2/lamedb
rm -rf /etc/enigma2/*list
rm -rf /etc/enigma2/*.tv
rm -rf /etc/enigma2/*.radio
rm -rf /etc/enigma2/epg.dat
rm -rf /etc/enigma2/timers.xml
rm -rf /home/root/.cache/enigma2
#####################################################################################
echo "        INSTALLING NEW CHANNELS..."
cd /tmp || exit 1
if wget -q "${MY_URL}/channels_backup_by_Emil-Nabil.tar.gz"; then
    if [ -s channels_backup_by_Emil-Nabil.tar.gz ]; then
        tar -xzf channels_backup_by_Emil-Nabil.tar.gz -C /
        rm -f channels_backup_by_Emil-Nabil.tar.gz
        echo "        CHANNELS INSTALLED SUCCESSFULLY"
    else
        echo "        ERROR: Downloaded file is empty"
        rm -f channels_backup_by_Emil-Nabil.tar.gz
        exit 1
    fi
else
    echo "        ERROR: Failed to download channels file"
    exit 1
fi
cd >/dev/null 2>&1 || exit 1
echo "        WAITING 5 SECONDS TO WRITE FILES..."
sleep 5
echo ""
echo "        INSTALLING ASTRA-SM PATCH"
if command -v opkg >/dev/null 2>&1; then
    opkg update >/dev/null 2>&1
    opkg install astra-sm >/dev/null 2>&1
    echo "        ASTRA-SM INSTALLED"
else
    echo "        WARNING: opkg not found, skipping astra-sm installation"
fi
sleep 1
echo ""
echo ""
echo "****************************************************************************************************************************"
echo "#       CHANNEL INSTALLED SUCCESSFULLY       #"
echo "*********************************************************"
echo "********************************************************************************"
echo "   UPLOADED BY >>>> EMIL_NABIL"
sleep 4
echo "========================================================================================================================="
echo "        >>>> RESTARTING <<<<"
echo "**********************************************************************************"
if command -v wget >/dev/null 2>&1; then
    wget -qO - http://127.0.0.1/web/servicelistreload?mode=0 >/dev/null 2>&1
    sleep 2
    wget -qO - http://127.0.0.1/web/powerstate?newstate=3 >/dev/null 2>&1
    sleep 4
    echo "        GUI RESTARTED SUCCESSFULLY"
elif command -v killall >/dev/null 2>&1; then
    killall enigma2 2>/dev/null
    echo "        ENIGMA2 RESTARTED VIA KILLALL"
elif command -v systemctl >/dev/null 2>&1; then
    systemctl restart enigma2 2>/dev/null
    echo "        ENIGMA2 RESTARTED VIA SYSTEMCTL"
else
    echo "        WARNING: Could not restart enigma2 automatically"
    echo "        Please restart enigma2 manually"
fi
exit 0




