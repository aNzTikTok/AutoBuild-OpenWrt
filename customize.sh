#!/bin/bash

# Create config directory
mkdir -p openwrt/files/etc/config

# Force LuCI interface language to English
cat <<EOF > openwrt/files/etc/config/luci
config core 'main'
	option lang 'en'
EOF

# Set timezone to Malaysia (Kuala Lumpur)
cat <<EOF > openwrt/files/etc/config/system
config system
	option hostname 'OpenWrt'
	option timezone 'MST-8'
	option zonename 'Asia/Kuala Lumpur'
EOF

# Remove default root password
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings
