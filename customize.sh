#!/bin/bash

mkdir -p openwrt/files/etc/config
echo -e "config core 'main'\n\toption lang 'en'" > openwrt/files/etc/config/luci

sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/lean/default-settings/files/zzz-default-settings

