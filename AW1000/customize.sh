#!/bin/bash

# Create config folders
mkdir -p openwrt/files/etc/config
mkdir -p openwrt/files/etc

# Set system hostname, timezone
cat <<EOF > openwrt/files/etc/config/system
config system
	option hostname 'DOTYCAT'
	option timezone 'MST-8'
	option zonename 'Asia/Kuala Lumpur'
EOF

# Set default LuCI language to English
cat <<EOF > openwrt/files/etc/config/luci
config core 'main'
	option lang 'en'
EOF

# Change LuCI Web UI title (from LEDE to custom)
sed -i 's/LEDE/DOTYCAT/g' openwrt/package/lean/default-settings/files/zzz-default-settings

# Remove default root password (empty login)
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

# Set custom SSH banner with Dotycat design
curl -s https://raw.githubusercontent.com/intannajwa/Auto_Build/master/banner -o openwrt/files/etc/banner

mkdir -p openwrt/files/etc/uci-defaults
cat <<EOF > openwrt/files/etc/uci-defaults/99-custom-wifi
uci set wireless.@wifi-device[0].type='mac80211'
uci set wireless.@wifi-device[0].channel='6'
uci set wireless.@wifi-device[0].hwmode='11a'
uci set wireless.@wifi-device[0].path='platform/18000000.wmac'
uci set wireless.@wifi-device[0].htmode='HT20'

uci set wireless.@wifi-iface[0].device='radio0'
uci set wireless.@wifi-iface[0].network='lan'
uci set wireless.@wifi-iface[0].mode='ap'
uci set wireless.@wifi-iface[0].ssid='DOTYCAT'
uci set wireless.@wifi-iface[0].encryption='none'
uci set wireless.@wifi-iface[0].disabled='0'

uci commit wireless
wifi reload
EOF
chmod +x openwrt/files/etc/uci-defaults/99-custom-wifi


# Auto-connect modem using ModemManager at boot
mkdir -p openwrt/files/etc/init.d
cat <<'EOF' > openwrt/files/etc/init.d/modem_autoconnect
#!/bin/sh /etc/rc.common
# Autostart ModemManager and connect using mmcli

START=95

start() {
    logger "Starting ModemManager and waiting for modem..."

    /etc/init.d/modemmanager start
    sleep 3

    # Wait up to 30 seconds for /dev/ttyUSB2 to appear
    for i in $(seq 1 30); do
        if [ -e /dev/ttyUSB2 ]; then
            logger "Modem device detected: /dev/ttyUSB2"
            break
        fi
        sleep 1
    done

    if [ ! -e /dev/ttyUSB2 ]; then
        logger "Modem not detected. Aborting APN setup."
        exit 1
    fi

    logger "Connecting to mobile network using APN..."
    mmcli -m 0 --simple-connect="apn=internet" || logger "ModemManager failed to connect."
}
EOF

chmod +x openwrt/files/etc/init.d/modem_autoconnect
mkdir -p openwrt/files/etc/rc.d
ln -s ../init.d/modem_autoconnect openwrt/files/etc/rc.d/S95modem_autoconnect

