#!/bin/bash -ex

#target=ix4-200d
version=5.19.12
dir=/dist/linux-$version

if [ ! -d $dir ]; then
# http://deb.debian.org/debian/pool/main/l/linux/linux_5.10.140.orig.tar.xz
# http://deb.debian.org/debian/pool/main/l/linux/linux_5.10.140-1.debian.tar.xz
  wget https://cdn.kernel.org/pub/linux/kernel/v${version:0:1}.x/linux-$version.tar.xz
  tar xvf linux-$version.tar.xz -C /dist
fi

cd $dir

export ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-


# KERNEL_XZ=y
# CLOCKSOURCE_WATCHDOG_MAX_SKEW_U=100
# PREEMPT_DYNAMIC=y
# TIME_NS=y
# ./scripts/config -m CONFIG_GPIO_PCA953X -d GPIO_PCA953X_IRQ -m CONFIG_GPIO_74X164 -m CONFIG_SPI_GPIO

make mrproper

cp /scripts/linux/.config $dir
# make ARCH=arm olddefconfig
#make allyesconfig

# make prepare; make modules_prepare; make scripts
#make menuconfig
# make prepare

make -j`nproc`

make -j`nproc` bindeb-pkg

#     nice make -j`nproc` bindeb-pkg 

exit

git config user.email "john@doe.xyz"; git config user.name "John Doe"

# Check what changes with similar DNS-325
# git diff tags/$oldVersion tags/$newVersion -- arch/arm/dts/kirkwood-dns* board/d-link/dns325/* configs/dns325* include/configs/dns325*

# Commands to recreate patch for a new version
# oldVersion=v2020.04 newVersion=v2022.01 patch=usbtimeoutfix
# oldVersion=v2020.04 newVersion=v2022.01 patch=dns320
# git checkout tags/$oldVersion; git checkout -b $oldVersion-$patch; git am --committer-date-is-author-date < ~/$oldVersion-$patch.patch
# git checkout tags/$newVersion; git merge --squash $oldVersion-$patch; # Resolve conflicts and report changes from DNS-325......
# git commit -m "$newVersion-$patch"; git format-patch --stdout HEAD~1 > ~/$newVersion-$patch.patch

# Apply `EHCI timed out on TD` patch from https://forum.doozan.com/read.php\?3,35295
# git am --committer-date-is-author-date < /scripts/$version-usbtimeoutfix.patch
# Apply DNS-320 support patch from https://github.com/avoidik/board_dns320
# git am --committer-date-is-author-date < /scripts/$version-dns320.patch
git pull https://github.com/ggirou/u-boot.git v2022.07-ix4-200d

export ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
make distclean
make ${target}_config
# make menuconfig

make u-boot.kwb

# make cross_tools

cp u-boot.kwb /dist/${target}-u-boot-${version}.kwb
cp arch/arm/dts/kirkwood-ix4-200d.dtb /dist
cp tools/kwboot /dist
