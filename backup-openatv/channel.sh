#!/bin/sh
#
# Command:
# wget -qO - https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv/channel.sh | /bin/sh
#
# ###########################################################

MY_URL="https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv"

echo "******************************************************************************************************************"
echo "        DOWNLOAD AND INSTALL CHANNEL"
echo "=================================================================================================================="

if [ -f /etc/opkg/opkg.conf ]; then
    STATUS="/var/lib/opkg/status"
    OSTYPE="Opensource"
    OPKG="opkg update"
    OPKGINSTAL="opkg install"
fi

echo "        REMOVE OLD CHANNELS..."

rm -f /etc/enigma2/lamedb
rm -f /etc/enigma2/*.list
rm -f /etc/enigma2/*.tv
rm -f /etc/enigma2/*.radio

echo "        INSTALLING NEW CHANNELS..."

cd /tmp || exit 1
set -e

wget -q "${MY_URL}/channels_backup_by_Emil-Nabil.tar.gz" -O channels_backup_by_Emil-Nabil.tar.gz
tar -xzf channels_backup_by_Emil-Nabil.tar.gz -C /

set +e
rm -f channels_backup_by_Emil-Nabil.tar.gz

sleep 2

echo ""
echo "        INSTALLING ASTRA-SM PATCH"

if command -v opkg >/dev/null 2>&1; then
    opkg update >/dev/null 2>&1
    opkg install -y astra-sm >/dev/null 2>&1
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

exit 0


