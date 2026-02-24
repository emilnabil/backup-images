#!/bin/sh
## setup command=wget https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv_7.6.sh -O - | /bin/sh
##################################

set -e

echo "Updating system..."
opkg update

echo "Installing curl..."
opkg install curl
sleep 2

echo "Updating all python..."
sleep 2
wget -qO - https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh | /bin/sh

# Download and extract the package
cd /tmp || exit 1

echo "Downloading package part 1..."
curl -k -L --connect-timeout 60 --max-time 600 \
"https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv_7.6_1.tar.gz" \
-o backup-openatv_7.6_1.tar.gz

echo "Downloading package part 2..."
curl -k -L --connect-timeout 60 --max-time 600 \
"https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv_7.6_2.tar.gz" \
-o backup-openatv_7.6_2.tar.gz

echo "Installing ...."
tar -xzf backup-openatv_7.6_1.tar.gz -C /
sleep 2
tar -xzf backup-openatv_7.6_2.tar.gz -C /
sleep 2

echo "Cleaning up..."
rm -f backup-openatv_7.6_1.tar.gz
rm -f backup-openatv_7.6_2.tar.gz

echo "Done ✔"
killall -9 enigma2

exit 0


