#!/bin/bash
## setup command=wget https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openbh/backup-openbh.sh -O - | /bin/sh

reboot() { :; }
init() { :; }
shutdown() { :; }
killall() {
    for arg in "$@"; do
        if [ "$arg" = "enigma2" ]; then
            return 0
        fi
    done
    return 0
}
systemctl() {
    case "$1" in
        reboot|poweroff|halt|shutdown|restart)
            return 0
            ;;
        *)
            command systemctl "$@"
            ;;
    esac
}
export -f reboot init shutdown killall systemctl

LOG_FILE="/tmp/superscript_$(date +%F_%H-%M-%S).log"
exec 3>&1 1>>"$LOG_FILE" 2>&1
trap 'echo "⚠ Script interrupted. Check $LOG_FILE for details." >&3' INT TERM

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

echo "==> Detecting OS..." >&3
OS="Unknown"
if command -v apt-get >/dev/null 2>&1; then
    OS='DreamOS'
elif command -v opkg >/dev/null 2>&1; then
    OS='Opensource'
fi
echo "✔ Detected OS: $OS" >&3
echo "" >&3

echo "==> Checking Python version..." >&3
PYTHON=""
if command -v python3 >/dev/null 2>&1 && python3 --version 2>&1 | grep -q '^Python 3\.'; then
    echo "✔ You have Python3" >&3
    PYTHON='PY3'
elif command -v python >/dev/null 2>&1 && python --version 2>&1 | grep -q '^Python 2\.'; then
    echo "✔ You have Python2" >&3
    PYTHON='PY2'
else
    echo "⚠ Python 2 or 3 is required but not found, continuing anyway" >&3
    PYTHON='PY2'
fi
echo "" >&3

echo "==> Updating feed and packages..." >&3
if wget -q --timeout=10 --tries=2 "https://raw.githubusercontent.com/emil237/updates-enigma/main/update-all-python.sh" -O /tmp/update-all-python.sh; then
    if [ -s /tmp/update-all-python.sh ]; then
        chmod +x /tmp/update-all-python.sh
        (bash /tmp/update-all-python.sh) >&3 2>&1
        rm -f /tmp/update-all-python.sh
    else
        echo "⚠ Update script is empty" >&3
    fi
else
    echo "⚠ Failed to download update script" >&3
fi

echo "Downloading package ..." >&3
if curl -k -L --connect-timeout 60 --max-time 600 \
    "https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openbh/backup-openbh.tar.gz" \
    -o backup-openbh.tar.gz 2>/dev/null; then
    
    if [ -s backup-openbh.tar.gz ]; then
        echo "Installing ...." >&3
        if tar -xzf backup-openbh.tar.gz -C / 2>/dev/null; then
            echo "✔ Extraction completed" >&3
        else
            echo "⚠ Failed to extract package" >&3
        fi
    else
        echo "⚠ Downloaded file is empty" >&3
    fi
else
    echo "⚠ Failed to download package" >&3
fi

echo "Cleaning up..." >&3
rm -f backup-openbh.tar.gz

IPAUDIO_VER="8.2"

echo "" >&3
echo "==> Cleaning cache..." >&3
if [ "$OS" = "Opensource" ]; then
    rm -rf /var/cache/opkg/* >/dev/null 2>&1
    rm -rf /var/lib/opkg/lists/* >/dev/null 2>&1
    rm -rf /run/opkg.lock >/dev/null 2>&1
    echo "✔ opkg cache cleaned" >&3
    opkg update >/dev/null 2>&1 && echo "✔ Feeds updated" >&3 || echo "⚠ Failed to update feeds" >&3
elif [ "$OS" = "DreamOS" ]; then
    apt-get clean >/dev/null 2>&1 && echo "✔ apt cache cleaned" >&3
    apt-get update >/dev/null 2>&1 && echo "✔ Feeds updated" >&3 || echo "⚠ Failed to update feeds" >&3
else
    echo "⚠ Skipping cache cleaning" >&3
fi

run_script() {
    local url="$1"
    local tmp_script="/tmp/plugin_installer_$(date +%s)_$$.sh"
    echo "▶ Downloading $url..." >&3
    
    set +e
    
    if wget -q --timeout=10 --tries=2 -O "$tmp_script" "$url"; then
        if [ -s "$tmp_script" ]; then
            chmod +x "$tmp_script"
            (bash "$tmp_script") >&3 2>&1
            local exit_code=$?
            if [ $exit_code -eq 0 ]; then
                echo "✔ Script $url executed successfully" >&3
            else
                echo "⚠ Failed to execute script $url (exit code: $exit_code) - Continuing..." >&3
            fi
            rm -f "$tmp_script"
        else
            echo "⚠ Downloaded script $url is empty - Continuing..." >&3
            rm -f "$tmp_script"
        fi
    else
        echo "⚠ Failed to download script $url - Continuing..." >&3
    fi
    
    set -e
}

echo "" >&3
echo "==> Installing Plugins for $PYTHON ..." >&3
urls=(
    "http://dreambox4u.com/emilnabil237/plugins/ajpanel/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/ajpanel/new/emil-panel-lite.sh"
    "https://dreambox4u.com/emilnabil237/plugins/ArabicSavior/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/cccaminfo/cccaminfo_${PYTHON,,}.sh"
    "https://dreambox4u.com/emilnabil237/plugins/crashlogviewer/CrashLogViewer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/EmilPanelPro/emilpanelpro.sh"
    "https://dreambox4u.com/emilnabil237/plugins/Epg-Grabber/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/iptosat/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/ipaudio/ipaudio-$IPAUDIO_VER.sh"
    "https://dreambox4u.com/emilnabil237/plugins/jedimakerxtream/installer.sh"
    "https://dreambox4u.com/emilnabil237/KeyAdder/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiCamAdder/installer.sh"
    "https://raw.githubusercontent.com/emilnabil/download-plugins/refs/heads/main/MultiIptvAdder/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/NewVirtualKeyBoard/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/RaedQuickSignal/installer.sh"
    "https://dreambox4u.com/emilnabil237/plugins/xtreamity/installer.sh"
    "https://raw.githubusercontent.com/popking159/skins/refs/heads/main/aglarepli/installer.sh"
    "https://dreambox4u.com/emilnabil237/emu/installer-cccam.sh"
    "https://dreambox4u.com/emilnabil237/emu/installer-ncam.sh"
    "https://raw.githubusercontent.com/levi-45/Levi45Emulator/main/installer.sh"

"https://raw.githubusercontent.com/emilnabil/channel-emil-nabil/main/installer.sh"

"https://github.com/emilnabil/backup-images/raw/refs/heads/main/backup-openbh/restore-settings.sh"
)

set +e

if [ -n "$PYTHON" ]; then
    for url in "${urls[@]}"; do
        run_script "$url"
        sleep 1
    done
else
    echo "⚠ Python version not detected, skipping plugin installation" >&3
fi

set -e

echo "" >&3
echo "==> Cleaning temporary files..." >&3
find /tmp -name "plugin_installer_*.sh" -delete 2>/dev/null && echo "✔ Temporary files cleaned" >&3 || echo "⚠ No temporary files found to clean" >&3

echo "" >&3
cd /tmp || { echo "⚠ Failed to change to /tmp directory" >&3; exit 1; }

echo "Done ✔" >&3
echo "#>>>>>> Uploaded By Emil Nabil <<<<<<<#" >&3
echo "✔ All steps completed!" >&3

echo "🔁 Rebooting device to apply changes..." >&3
sleep 4

unset -f reboot init shutdown killall systemctl 2>/dev/null

if command -v reboot >/dev/null 2>&1; then
    echo "✅ Using reboot command" >&3
    sleep 2
    command reboot
elif command -v init >/dev/null 2>&1; then
    echo "✅ Using init 6 command" >&3
    sleep 2
    command init 6
elif command -v systemctl >/dev/null 2>&1; then
    echo "✅ Using systemctl reboot command" >&3
    sleep 2
    command systemctl reboot
else
    echo "❌ Reboot failed - no reboot command found" >&3
    echo "❌ Please reboot manually" >&3
    if command -v killall >/dev/null 2>&1; then
        echo "📱 Attempting to restart enigma2..." >&3
        killall enigma2 2>/dev/null
    fi
fi

echo "Script finished at: $(date)" >&3

exit 0




