Build u-boot

# Needed dependencies

https://u-boot.readthedocs.io/en/latest/build/gcc.html#dependencies

    sudo apt-get update
    sudo apt-get install -y make gcc gcc-arm-none-eabi gcc-arm-linux-gnueabi gcc-x86-64-linux-gnux32 u-boot-tools git bison flex libncurses5-dev libncursesw5-dev libssl-dev

# Get sources

    git clone -b v2022.04 https://github.com/u-boot/u-boot.git
    cd u-boot/

# Build

    export ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-
    make distclean
    # make sheevaplug_config
    make ix4-200d_config
    make u-boot.kwb

    # Copy latest kwboot
    sudo cp ./tools/kwboot /usr/bin
