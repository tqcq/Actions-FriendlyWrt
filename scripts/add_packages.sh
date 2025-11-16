#!/bin/bash

# {{ Add luci-app-diskman
(cd friendlywrt && {
    mkdir -p package/luci-app-diskman
    wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile.old -O package/luci-app-diskman/Makefile
})
cat >>configs/rockchip/01-nanopi <<EOL
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y
CONFIG_PACKAGE_smartmontools=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_vlmcsd=y
CONFIG_PACKAGE_ffmpeg-static=y
CONFIG_PACKAGE_luci-app-bandwidthd=y
CONFIG_PACKAGE_luci-app-tailscale=y
CONFIG_PACKAGE_tailscale=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_zerotier=y
CONFIG_PACKAGE_luci-app-easytier=y
CONFIG_PACKAGE_adguardhome=y
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-adguardhome_INCLUDE_binary=y
EOL
# }}

# {{ Add luci-theme-argon
(cd friendlywrt/package && {
    [ -d luci-theme-argon ] && rm -rf luci-theme-argon
    git clone https://github.com/jerrykuku/luci-theme-argon.git --depth 1 -b master
})
echo "CONFIG_PACKAGE_luci-theme-argon=y" >>configs/rockchip/01-nanopi
sed -i -e 's/function init_theme/function old_init_theme/g' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
sed -i -e 's|192.168.|10.10.|g' friendlywrt/package/base-files/files/bin/config_generate
echo 'src-git smpackage https://code.uocat.com/tqcq/small-package.git^7c1fec56b7193f468982341c99daaaa0e2f8e1a5' >>friendlywrt/feeds.conf.default

cat >/tmp/appendtext.txt <<EOL
function init_theme() {
    if uci get luci.themes.Argon >/dev/null 2>&1; then
        uci set luci.main.mediaurlbase="/luci-static/argon"
        uci commit luci
    fi
}
EOL
sed -i -e '/boardname=/r /tmp/appendtext.txt' friendlywrt/target/linux/rockchip/armv8/base-files/root/setup.sh
# }}
