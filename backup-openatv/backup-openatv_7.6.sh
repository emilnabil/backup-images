#!/bin/bash
## setup command=wget https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv/backup-openatv_7.6.sh -O - | /bin/sh
##################################

# Download and extract the package
cd /tmp || exit 1

echo "Downloading package ..."
curl -k -L --connect-timeout 60 --max-time 600 \
    "https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv/backup-openatv_7.6.tar.gz" \
    -o backup-openatv_7.6.tar.gz

echo "Installing ...."
tar -xzf backup-openatv_7.6.tar.gz -C /
sleep 2

echo "Cleaning up..."
rm -f backup-openatv_7.6.tar.gz

echo "Done ✔"

# Override system commands to prevent accidental reboots during installation
reboot() { :; }
init() { :; }
shutdown() { :; }
killall() {
    for arg in "$@"; do
        if [ "$arg" = "enigma2" ]; then
            :  # Do nothing if trying to kill enigma2
            return 0
        fi
    done
    :  # Do nothing for other processes as well
    return 0
}
systemctl() {
    case "$1" in
        reboot|poweroff|halt|shutdown|restart)
            :  # Suppress systemctl reboot commands
            ;;
        *)
            command systemctl "$@"
            ;;
    esac
}
export -f reboot init shutdown killall systemctl

DISABLE_RESTART=true
LOG_FILE="/tmp/superscript_$(date +%F_%H-%M-%S).log"
exec 3>&1 1>>"$LOG_FILE" 2>&1
trap 'echo "⚠ Script interrupted. Check $LOG_FILE for details."' INT TERM

printf "\n\n" >&3
echo "===========================================================" >&3
echo "     ★ Super_Script & Plugin Installer by Emil Nabil ★" >&3
echo "             Version: February 2026" >&3
echo "===========================================================" >&3
echo "Started at: $(date)" >&3
echo "" >&3
echo "Install tools & packages" >&3
echo "Install useful plugins" >&3
echo "" >&3

echo "==> Gathering system info..." >&3
[ -f /etc/image-version ] && grep -i 'distro' /etc/image-version | cut -d= -f2 >&3 || echo "⚠ No distro info found" >&3
[ -f /etc/hostname ] && cat /etc/hostname >&3 || echo "⚠ No hostname info found" >&3
ip -o -4 route show to default 2>/dev/null | awk '{print $5}' >&3 || echo "eth0" >&3
echo "" >&3

echo "==> Updating feed and packages..." >&3
if command -v opkg >/dev/null 2>&1; then
    opkg update >/dev/null 2>&1 && echo "✔ Feeds updated" >&3 || echo "⚠ Failed to update feeds" >&3
    opkg upgrade >/dev/null 2>&1 && echo "✔ Packages upgraded" >&3 || echo "⚠ Some packages failed to upgrade" >&3
elif command -v apt-get >/dev/null 2>&1; then
    apt-get update >/dev/null 2>&1 && echo "✔ Feeds updated" >&3 || echo "⚠ Failed to update feeds" >&3
    apt-get upgrade -y >/dev/null 2>&1 && echo "✔ Packages upgraded" >&3 || echo "⚠ Some packages failed to upgrade" >&3
else
    echo "⚠ Neither opkg nor apt-get found" >&3
fi
echo "" >&3

echo "==> Installing essential packages..." >&3
essential_packages=("xz" "curl" "wget" "ntpd" "bzip2" "unrar" "zip" "zstd" "openvpn" "rtmpdump" "duktape" "dvbsnoop" "libusb-1.0-0" "libxml2" "libxslt" "alsa-plugins" "astra-sm")
for pkg in "${essential_packages[@]}"; do
    if command -v opkg >/dev/null 2>&1; then
        opkg install "$pkg" >/dev/null 2>&1 && echo "✔ $pkg installed" >&3 || echo "⚠ Failed to install $pkg" >&3
    elif command -v apt-get >/dev/null 2>&1; then
        apt-get install -y "$pkg" >/dev/null 2>&1 && echo "✔ $pkg installed" >&3 || echo "⚠ Failed to install $pkg" >&3
    fi
done
echo "" >&3

echo "==> Checking Python version..." >&3
if command -v python3 >/dev/null 2>&1 && python3 --version 2>&1 | grep -q '^Python 3\.'; then
    echo "✔ You have Python3" >&3
    PYTHON='PY3'
elif command -v python2 >/dev/null 2>&1 && python2 --version 2>&1 | grep -q '^Python 2\.'; then
    echo "✔ You have Python2" >&3
    PYTHON='PY2'
else
    echo "⚠ Python 2 or 3 is required but not found, continuing anyway" >&3
    PYTHON='PY2'
fi
echo "" >&3

echo "==> Detecting OS..." >&3
if command -v apt-get >/dev/null 2>&1; then
    INSTALL="apt-get install -y"
    CHECK_INSTALLED="dpkg -s"
    OS='DreamOS'
elif command -v opkg >/dev/null 2>&1; then
    INSTALL="opkg install --force-reinstall --force-depends"
    CHECK_INSTALLED="opkg status"
    OS='Opensource'
else
    echo "⚠ Unsupported OS, continuing with basic operations" >&3
    OS='Unknown'
fi
echo "✔ Detected OS: $OS" >&3
echo "" >&3

echo "==> Installing required packages for $PYTHON ..." >&3
declare -A packages
if [ "$PYTHON" = 'PY3' ]; then
    packages=(
        ["p7zip"]=1 ["wget"]=1 ["curl"]=1 ["python3-lxml"]=1 ["python3-requests"]=1
        ["python3-beautifulsoup4"]=1 ["python3-cfscrape"]=1 ["livestreamersrv"]=1
        ["python3-six"]=1 ["python3-sqlite3"]=1 ["python3-pycrypto"]=1 ["f4mdump"]=1
        ["python3-image"]=1 ["python3-imaging"]=1 ["python3-argparse"]=1
        ["python3-multiprocessing"]=1 ["python3-mmap"]=1 ["python3-ndg-httpsclient"]=1
        ["python3-pydoc"]=1 ["python3-xmlrpc"]=1 ["python3-certifi"]=1 ["python3-urllib3"]=1
        ["python3-chardet"]=1 ["python3-pysocks"]=1 ["python3-js2py"]=1 ["python3-pillow"]=1
        ["enigma2-plugin-systemplugins-serviceapp"]=1 ["ffmpeg"]=1 ["exteplayer3"]=1
        ["gstplayer"]=1 ["gstreamer1.0-plugins-good"]=1 ["gstreamer1.0-plugins-ugly"]=1
        ["gstreamer1.0-plugins-base"]=1 ["gstreamer1.0-plugins-bad"]=1
        ["python3-codecs"]=1 ["python3-compression"]=1 ["python3-difflib"]=1
        ["python3-html"]=1 ["python3-misc"]=1 ["python3-shell"]=1
        ["python3-twisted-web"]=1 ["python3-unixadmin"]=1 ["python3-treq"]=1
        ["python3-core"]=1 ["python3-cryptography"]=1 ["python3-json"]=1
        ["python3-netclient"]=1 ["python3-pyopenssl"]=1 ["python3-futures3"]=1
        ["python3-backports-lzma"]=1 ["python3-dateutil"]=1 ["python3-fuzzywuzzy"]=1
        ["python3-future"]=1 ["python3-levenshtein"]=1 ["python3-mechanize"]=1
        ["python3-netserver"]=1 ["python3-pkgutil"]=1 ["python3-pycurl"]=1
        ["python3-pycryptodome"]=1 ["python3-rarfile"]=1 ["python3-requests-cache"]=1
        ["python3-transmission-rpc"]=1 ["python3-zoneinfo"]=1
        ["alsa-utils"]=1 ["alsa-utils-aplay"]=1 ["alsa-conf"]=1 ["alsa-state"]=1
        ["libasound2"]=1 ["transmission"]=1 ["transmission-client"]=1
        ["enigma2-plugin-extensions-e2iplayer-deps"]=1
        ["perl-module-io-zlib"]=1 ["kernel-module-nandsim"]=1 ["mtd-utils-jffs2"]=1
        ["lzo"]=1 ["util-linux-sfdisk"]=1 ["packagegroup-base-nfs"]=1 ["ofgwrite"]=1
        ["mtd-utils"]=1 ["mtd-utils-ubifs"]=1 ["apt-transport-https"]=1
    )
else
    packages=(
        ["wget"]=1 ["curl"]=1 ["hlsdl"]=1 ["python-lxml"]=1 ["python-requests"]=1
        ["python-beautifulsoup4"]=1 ["python-cfscrape"]=1 ["livestreamer"]=1
        ["python-six"]=1 ["python-sqlite3"]=1 ["python-pycrypto"]=1
        ["f4mdump"]=1 ["python-image"]=1 ["python-imaging"]=1 ["python-argparse"]=1
        ["python-multiprocessing"]=1 ["python-mmap"]=1 ["python-ndg-httpsclient"]=1
        ["python-pydoc"]=1 ["python-xmlrpc"]=1 ["python-certifi"]=1 ["python-urllib3"]=1
        ["python-chardet"]=1 ["python-pysocks"]=1 ["enigma2-plugin-systemplugins-serviceapp"]=1
        ["ffmpeg"]=1 ["exteplayer3"]=1 ["gstplayer"]=1 ["gstreamer1.0-plugins-good"]=1
        ["gstreamer1.0-plugins-ugly"]=1 ["gstreamer1.0-plugins-base"]=1 ["gstreamer1.0-plugins-bad"]=1
        ["python-codecs"]=1 ["python-compression"]=1 ["python-difflib"]=1
        ["python-html"]=1 ["python-misc"]=1 ["python-shell"]=1
        ["python-subprocess"]=1 ["python-twisted-web"]=1 ["python-unixadmin"]=1
        ["python-cryptography"]=1 ["python-json"]=1 ["python-netclient"]=1
        ["python-pyopenssl"]=1 ["python-futures"]=1 ["python-lzma"]=1
        ["python-mechanize"]=1 ["python-robotparser"]=1 ["python-argparse"]=1
        ["alsa-utils"]=1 ["alsa-utils-aplay"]=1 ["alsa-conf"]=1 ["alsa-state"]=1
        ["libasound2"]=1 ["transmission"]=1 ["transmission-client"]=1
        ["enigma2-plugin-extensions-e2iplayer-deps"]=1
        ["perl-module-io-zlib"]=1 ["kernel-module-nandsim"]=1 ["mtd-utils-jffs2"]=1
        ["lzo"]=1 ["util-linux-sfdisk"]=1 ["packagegroup-base-nfs"]=1 ["ofgwrite"]=1
        ["mtd-utils"]=1 ["mtd-utils-ubifs"]=1 ["apt-transport-https"]=1 ["duktape"]=1
        ["astra-sm"]=1 ["gstplayer"]=1 ["p7zip"]=1 ["rtmpdump"]=1 ["libusb-1.0-0"]=1
        ["unrar"]=1 ["libxml2"]=1 ["libxslt"]=1
    )
fi

for package in "${!packages[@]}"; do
    if ! $CHECK_INSTALLED "$package" >/dev/null 2>&1; then
        echo "Installing $package..." >&3
        $INSTALL "$package" >/dev/null 2>&1 && echo "✔ $package installed" >&3 || echo "⚠ Failed to install $package" >&3
    else
        echo "✔ $package is already installed" >&3
    fi
done

echo "" >&3
echo "==> Installing additional Python-specific libraries..." >&3
python_version=$(python3 --version 2>&1 | awk '{print $2}' 2>/dev/null)
if [ $? -ne 0 ]; then
    python_version=$(python --version 2>&1 | awk '{print $2}' 2>/dev/null)
fi

case $python_version in
    2.7.*)
        echo "Installing Python 2.7 specific libraries..." >&3
        $INSTALL libavcodec58 libavformat58 libpython2.7-1.0 >/dev/null 2>&1 && echo "✔ Python 2.7 libraries installed" >&3 || echo "⚠ Failed to install Python 2.7 libraries" >&3
        ;;
    3.9.*)
        echo "Installing Python 3.9 specific libraries..." >&3
        $INSTALL libavcodec58 libavformat58 libpython3.9-1.0 >/dev/null 2>&1 && echo "✔ Python 3.9 libraries installed" >&3 || echo "⚠ Failed to install Python 3.9 libraries" >&3
        ;;
    3.10.*)
        echo "Installing Python 3.10 specific libraries..." >&3
        $INSTALL libavcodec60 libavformat60 libpython3.10-1.0 >/dev/null 2>&1 && echo "✔ Python 3.10 libraries installed" >&3 || echo "⚠ Failed to install Python 3.10 libraries" >&3
        ;;
    3.11.*)
        echo "Installing Python 3.11 specific libraries..." >&3
        $INSTALL libavcodec60 libavformat60 libpython3.11-1.0 >/dev/null 2>&1 && echo "✔ Python 3.11 libraries installed" >&3 || echo "⚠ Failed to install Python 3.11 libraries" >&3
        ;;
    3.12.*)
        echo "Installing Python 3.12 specific libraries..." >&3
        $INSTALL libavcodec60 libavformat60 libpython3.12-1.0 >/dev/null 2>&1 && echo "✔ Python 3.12 libraries installed" >&3 || echo "⚠ Failed to install Python 3.12 libraries" >&3
        ;;
    3.13.*)
        echo "Installing Python 3.13 specific libraries..." >&3
        $INSTALL libavcodec60 libavformat60 libpython3.13-1.0 >/dev/null 2>&1 && echo "✔ Python 3.13 libraries installed" >&3 || echo "⚠ Failed to install Python 3.13 libraries" >&3
        ;;
    *)
        echo "No specific libraries for Python version $python_version" >&3
        ;;
esac

if [ "$PYTHON" = "PY3" ]; then
    IPAUDIO_VER="8.2"
else
    IPAUDIO_VER="8.2"
fi

echo "" >&3
echo "==> Cleaning cache..." >&3
if [ "$OS" = "Opensource" ]; then
    rm -rf /var/cache/opkg/* >/dev/null 2>&1
    rm -rf /var/lib/opkg/lists/* >/dev/null 2>&1
    rm -rf /run/opkg.lock >/dev/null 2>&1
    echo "✔ opkg cache cleaned" >&3
    opkg update >/dev/null 2>&1 && echo "✔ Feeds updated" >&3
else
    apt-get clean >/dev/null 2>&1 && echo "✔ apt cache cleaned" >&3
fi

run_script() {
    local url="$1"
    local tmp_script="/tmp/plugin_installer_$(date +%s).sh"
    echo "▶ Downloading $url..." >&3
    if wget -q --timeout=10 --tries=2 -O "$tmp_script" "$url"; then
        if [ -s "$tmp_script" ]; then
            chmod +x "$tmp_script"
            if bash "$tmp_script"; then
                echo "✔ Script $url executed successfully" >&3
            else
                echo "⚠ Failed to execute script $url" >&3
            fi
            rm -f "$tmp_script"
        else
            echo "⚠ Downloaded script $url is empty" >&3
            rm -f "$tmp_script"
        fi
    else
        echo "⚠ Failed to download script $url" >&3
    fi
}

echo "" >&3
echo "==> Installing Plugins for $PYTHON ..." >&3
urls=(
    "http://dreambox4u.com/emilnabil237/plugins/ajpanel/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/ajpanel/new/emil-panel-lite.sh"
    "https://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo/cccaminfo_${PYTHON,,}.sh"
    "https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/CrashLogViewer.sh"
    "https://github.com/emilnabil/download-plugins/raw/refs/heads/main/EmilPanel/emilpanel.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/EmilPanelPro/emilpanelpro.sh"
    "https://dreambox4u.com/emilnabil237/plugins/Epg-Grabber/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/iptosat/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/ipaudio/ipaudio-$IPAUDIO_VER.sh"
    "https://dreambox4u.com/emilnabil237/plugins/jedimakerxtream/installer.sh"
    "https://dreambox4u.com/emilnabil237/KeyAdder/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiCamAdder/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiIptvAdder/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/multi-stalkerpro/main/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/NewVirtualKeyBoard/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/RaedQuickSignal/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/SmartAddonspanel/smart-Panel.sh"
    "https://dreambox4u.com/emilnabil237/plugins/xtreamity/installer.sh"
    "https://dreambox4u.com/emilnabil237/emu/installer-cccam.sh"
    "https://dreambox4u.com/emilnabil237/emu/installer-ncam.sh"
    "https://dreambox4u.com/emilnabil237/emu/installer-oscam.sh"
    "https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openatv/channel.sh"
)

for url in "${urls[@]}"; do
    run_script "$url"
    sleep 1
done

echo "" >&3
echo "==> Cleaning temporary files..." >&3
find /tmp -name "plugin_installer_*.sh" -delete && echo "✔ Temporary files cleaned" >&3 || echo "⚠ No temporary files found to clean" >&3

echo "" >&3
echo "#>>>>>> Uploaded By Emil Nabil <<<<<<<#" >&3
echo "✔ All steps completed!" >&3

if [ "${DISABLE_RESTART,,}" = "true" ]; then
    echo "🔁 Restarting device to apply changes..." >&3
    sleep 4
    command reboot || echo "⚠ Failed to restart enigma2" >&3
else
    echo "ℹ Restart skipped (DISABLE_RESTART = $DISABLE_RESTART)" >&3
fi

echo "Script finished at: $(date)" >&3

exit 0



