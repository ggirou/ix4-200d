

# Build missing module

    #sudo apt-get install build-essential linux-source bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison 
    sudo apt install linux-source libssl-dev linux-headers-$(uname -r)

    cd ~
    tar xvf /usr/src/linux-source-5.18.tar.xz

    cd linux-source-5.18
    xz -dc /usr/src/linux-patch-5.18-rt.patch.xz | patch -p1

    # make mrproper

    cp /usr/src/linux-headers-$(uname -r)/Module.symvers .

    make olddefconfig
    ./scripts/config -m CONFIG_GPIO_PCA953X -d GPIO_PCA953X_IRQ -m CONFIG_GPIO_74X164 -m CONFIG_SPI_GPIO -m CONFIG_AHCI_MVEBU

    make prepare; make modules_prepare; make scripts
    make M=drivers/ata
    make M=drivers/gpio
    make M=drivers/spi
    # make drivers/gpio/gpio-pca953x.ko

    # sudo insmod drivers/gpio/gpio-pca953x.ko

    sudo cp drivers/ata/*.ko /lib/modules/$(uname -r)/kernel/drivers/ata/
    sudo cp drivers/gpio/gpio-pca953x.ko drivers/gpio/gpio-74x164.ko /lib/modules/$(uname -r)/kernel/drivers/gpio/
    sudo cp drivers/spi/spi-gpio.ko drivers/spi/spi-bitbang.ko /lib/modules/$(uname -r)/kernel/drivers/spi/

    sudo depmod
    sudo modprobe ahci_mvebu
    sudo modprobe gpio-pca953x
    sudo modprobe -r spi-bitbang
    sudo modprobe spi-bitbang
    sudo modprobe spi-gpio
    sudo modprobe gpio-74x164

# Unused

    ./scripts/config -m CONFIG_I2C_MUX_PCA954x; sed -i 's/CONFIG_I2C_MUX_PCA954X/CONFIG_I2C_MUX_PCA954x/' .config
    #echo CONFIG_I2C_MUX_PCA954x=m >> .config
    make prepare; make modules_prepare; make scripts
    #make M=drivers/i2c
    make M=drivers/i2c/muxes
    sudo mkdir -p /lib/modules/$(uname -r)/kernel/drivers/i2c/muxes/
    sudo cp drivers/i2c/muxes/i2c-mux-pca954x.ko /lib/modules/$(uname -r)/kernel/drivers/i2c/muxes/

    sudo modprobe i2c-mux-pca954x
