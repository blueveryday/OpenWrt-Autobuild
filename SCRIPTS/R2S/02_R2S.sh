#!/bin/bash
clear

## Custom-made
# GCC CFlags for R2S
sed -i 's,-mcpu=generic,-march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53,g' include/target.mk
#sed -i 's/O2/O2/g' ./rules.mk
# IRQ
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 8 "ff160000" "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 1 "ff150000" "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
# Disabed rk3328 ethernet tcp/udp offloading tx/rx
sed -i '/;;/i\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
# Patch i2c0
#cp -f ../PATCH/new/main/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch ./target/linux/rockchip/patches-5.4/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch
# Overclock or not
cp -f ../PATCH/new/main/999-RK3328-enable-1512mhz-opp.patch ./target/linux/rockchip/patches-5.4/999-RK3328-enable-1512mhz-opp.patch
#cp -f ../PATCH/new/main/999-unlock-1608mhz-rk3328.patch ./target/linux/rockchip/patches-5.4/999-unlock-1608mhz-rk3328.patch
# Swap LAN & WAN
#patch -p1 < ../PATCH/new/main/0001-target-rockchip-swap-nanopi-r2s-lan-wan-port.patch
# Update r8152 driver
#wget -O- https://patch-diff.githubusercontent.com/raw/openwrt/openwrt/pull/3178.patch | patch -p1
#wget -O- https://github.com/immortalwrt/immortalwrt/commit/d8df86130d172b3ce262d2744e2ddd2a6eed5f50.patch | patch -p1
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/ctcgfw/r8152 package/new/r8152
sed -i '/rtl8152/d' ./target/linux/rockchip/image/armv8.mk
# 3328 Add idle
wget -P target/linux/rockchip/patches-5.4 https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/rockchip/patches-5.4/007-arm64-dts-rockchip-Add-RK3328-idle-state.patch
# Addition-Trans-zh-master
cp -rf ../PATCH/duplicate/addition-trans-zh-r2s ./package/lean/lean-translate
# Add cputemp.sh
wget https://raw.githubusercontent.com/nicholas-opensource/Others/master/cputemp.sh -O package/base-files/files/bin/cputemp.sh

<<'COMMENT'
#Vermagic
latest_version="$(curl -s https://github.com/openwrt/openwrt/releases |grep -Eo "v[0-9\.]+.tar.gz" |sed -n '/21/p' |sed -n 1p |sed 's/v//g' |sed 's/.tar.gz//g')"
wget https://downloads.openwrt.org/releases/${latest_version}/targets/rockchip/armv8/packages/Packages.gz
zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
COMMENT

# Crypto
echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_NEON=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
# CONFIG_CRYPTO_SHA3_ARM64 is not set
CONFIG_CRYPTO_SHA512_ARM64=y
# CONFIG_CRYPTO_SHA512_ARM64_CE is not set
CONFIG_CRYPTO_SIMD=y
# CONFIG_CRYPTO_SM3_ARM64_CE is not set
# CONFIG_CRYPTO_SM4_ARM64_CE is not set
' >> ./target/linux/rockchip/armv8/config-5.4