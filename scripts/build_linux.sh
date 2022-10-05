#!/bin/bash -ex

#target=ix4-200d
version=5.19.12
dir=/build/linux-$version
configfile=config-5.10.0-18.custom-marvell

if [ ! -d $dir ]; then
# http://deb.debian.org/debian/pool/main/l/linux/linux_5.10.140.orig.tar.xz
# http://deb.debian.org/debian/pool/main/l/linux/linux_5.10.140-1.debian.tar.xz
  wget https://cdn.kernel.org/pub/linux/kernel/v${version:0:1}.x/linux-$version.tar.xz
  tar xvf linux-$version.tar.xz -C /build
fi

cd $dir

export ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
export DEB_TARGET_ARCH=armel

# KERNEL_XZ=y
# CLOCKSOURCE_WATCHDOG_MAX_SKEW_U=100
# PREEMPT_DYNAMIC=y
# TIME_NS=y
# ./scripts/config -m CONFIG_GPIO_PCA953X -d GPIO_PCA953X_IRQ -m CONFIG_GPIO_74X164 -m CONFIG_SPI_GPIO

make mrproper

cp /scripts/linux/$configfile $dir/.config
make olddefconfig
# make ARCH=arm olddefconfig
#make allyesconfig

# make prepare; make modules_prepare; make scripts
#make menuconfig
# make prepare

# make -j`nproc`

make -j`nproc` bindeb-pkg

cp /build/*.{deb,buildinfo,changes} /dist
cp $dir/debian/linux-image/boot/* /dist
