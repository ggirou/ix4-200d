

# Build missing module

    #sudo apt-get install build-essential linux-source bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison 
    sudo apt install linux-source libssl-dev linux-headers-$(uname -r)

    cd ~
    tar xvf /usr/src/linux-source-5.10.tar.xz

    cd linux-source-5.10
    xz -dc /usr/src/linux-patch-5.10-rt.patch.xz | patch -p1

    # make mrproper

    make olddefconfig
    ./scripts/config -m CONFIG_GPIO_PCA953X -d GPIO_PCA953X_IRQ -m CONFIG_GPIO_74X164 -m CONFIG_SPI_GPIO

    cp /usr/src/linux-headers-$(uname -r)/Module.symvers .

    make prepare; make modules_prepare; make scripts
    make M=drivers/gpio
    make M=drivers/spi
    # make drivers/gpio/gpio-pca953x.ko

    # sudo insmod drivers/gpio/gpio-pca953x.ko

    sudo cp drivers/gpio/gpio-pca953x.ko drivers/gpio/gpio-74x164.ko /lib/modules/5.10.0-16-marvell/kernel/drivers/gpio/
    sudo cp drivers/spi/spi-gpio.ko drivers/spi/spi-bitbang.ko /lib/modules/5.10.0-16-marvell/kernel/drivers/spi/
    sudo depmod
    sudo modprobe gpio-pca953x
    sudo modprobe -r spi-bitbang
    sudo modprobe spi-bitbang
    sudo modprobe spi-gpio ### Poweroff !!! Prefer reboot
    sudo modprobe gpio-74x164 ### Poweroff !
