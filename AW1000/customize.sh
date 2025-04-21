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

# Enable and customize Wi-Fi
cat <<EOF > openwrt/files/etc/config/wireless
config wifi-device 'radio0'
	option type 'mac80211'
	option hwmode '11a'
	option path 'platform/18000000.wmac'
	option htmode 'HT20'
	option channel '6'

config wifi-iface
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'DOTYCAT'
	option encryption 'none'
	option disabled '0'
EOF

# Auto-connect modem using ModemManager at boot
mkdir -p openwrt/files/etc/init.d
cat <<'EOF' > openwrt/files/etc/init.d/modem_autoconnect
#!/bin/sh /etc/rc.common
# Autostart ModemManager and connect using mmcli

START=95

start() {
    logger "Starting ModemManager and connecting modem..."
    /etc/init.d/modemmanager start
    sleep 10  # Give ModemManager time to detect modem
    mmcli -m 0 --simple-connect="apn=internet"
}
EOF

chmod +x openwrt/files/etc/init.d/modem_autoconnect
mkdir -p openwrt/files/etc/rc.d
ln -s ../init.d/modem_autoconnect openwrt/files/etc/rc.d/S95modem_autoconnect

