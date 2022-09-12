ix4-200d latest offcial firmware
--------------------------------

# Download original firmware

    wget http://download.lenovo.com/nasupdate/iomnas/ix4-200d-3.2.16.30221.tgz
    openssl enc -d -md md5 -aes-128-cbc -in "ix4-200d-3.2.16.30221.tgz" -k "EMCNTGSOHO" -out "ix4-200d-3.2.16.30221-decrypted.tar.gz"
    tar xzf ix4-200d-3.2.16.30221-decrypted.tar.gz -C ./ix4-200d-3.2.16.30221/

Extracted files:

- `u-boot-DRAM256-MapowerV5.1_nand.bin`: U-Boot bootloader
- `initrd`: u-boot legacy uImage containing Linux RAMDisk Image
- `zImage`: u-boot legacy uImage containing Linux Kernel Image
- `apps`: ext2 filesystem containing Debian OS

## Few experiments

### Kernel

Extract kernel:

    dumpimage -l zImage
    dumpimage -o zImage.img zImage

### Initrd

Mount `initrd` filesystem:

    cd ix4-200d-3.2.16.30221/
    dumpimage -l initrd
    dumpimage -o initrd.img.gz initrd
    gunzip -v initrd.img.gz

    mkdir initrd.mnt
    sudo mount initrd.img initrd.mnt/

Files to note:

- `/linuxrc`: Shell script that runs on startup

### Debian image

Mount `apps` filesystem:

    cd ix4-200d-3.2.16.30221/
    mkdir apps.mnt
    sudo mount apps apps.mnt/

Files to note:

- `/usr/local/cfg/initrd_bootstrap.sh`: script that runs on Debian startup
- `/lib/modules/modprobe.txt`: loaded modules at startup
- `/etc/sensons.conf`: loaded modules at startup

# Boot u-boot and debian

    cd ix4-200d-3.2.16.30221

## Prepare USB key

    # Recreate MBR partition
    sudo apt-get install mbr
    sudo install-mbr /dev/sda
    
    # Create partition
    sudo parted -l
    sudo parted /dev/sda rm 1
    sudo parted /dev/sda mklabel msdos
    sudo parted -a optimal /dev/sda mkpart primary 0% 100%
    sudo parted /dev/sda set 1 boot on

    # Copy debian image
    sudo dd if=apps of=/dev/sda1 bs=1024
    sudo e2fsck -fy /dev/sda1
    # Optionnal
    # sudo resize2fs /dev/sda1

    # Copy kernel and initrd images to TFTP server
    sudo cp zImage initrd /srv/tftp/

    # OR Copy kernel and initrd images to usb
    sudo mkdir -p /mnt/usb/
    sudo mount /dev/sda1 /mnt/usb/
    sudo cp zImage initrd /mnt/usb/
    ls -la /mnt/usb/
    sudo umount /mnt/usb/

## Serial boot u-boot

    kwboot -p -t -B 115200 /dev/ttyUSB0 -b u-boot-DRAM256-MapowerV5.1_nand.bin

> Hit `Ctrl+C` several times to stop boot processes.

    # Load from TFTP server (plug on Ethernet port 2)
    setenv ipaddr 192.168.1.250; setenv serverip 192.168.1.48
    tftpboot 0x2000000 zImage; tftpboot 0x4500000 initrd

    # OR Load from USB (if it works!)
    usb start
    ext2ls usb 0 /
    ext2load usb 0:1 0x2000000 zImage
    ext2load usb 0:1 0x4500000 initrd

    setenv bootargs console=ttyS0,115200 mtdparts=nand_mtd:0xa0000@0x0(uboot),0x10000@0xa0000(env),0x224000@0xb0000(zImage),0x224000@0x2d4000(initrd),32m@0x0(flash) root=/dev/disk/by-path/platform-f1050000.ehci-usb-0:1.2:1.0-scsi-0:0:0:0-part1 rw
    bootm 0x2000000 0x4500000

    # FAIL TO BOOT!

# Download source code from Lenovo Lifeline FossKit

    wget http://download.lenovo.com/nas/foss/lenovoemc-lifeline-fosskit-20120827.zip
    unzip lenovoemc-lifeline-fosskit-20120827.zip

    cd EMCLifeline-GPL-Bellagio/

    tar xvf Lifeline_OSSKit/u-boot/u-boot-3.6.0.tar.bz2

    tar xvf Lifeline_OSSKit/linux-2.6.31.8.tar.bz2
    mv Lifeline_OSSKit/kernel/linux-2.6.31.8/ix4-200d/ .

    tar xvf debian_src_pkgs.tar

## Explore

Reminder:

    MARVELL BOARD: IX4-110 LE
    Soc: 88F6281 A1 (DDR2)

> LE: Little Endian


### Kernel

    grep -R -i 88F6281 linux-2.6.31.8/

### IX4-200d patches

    grep -R -i 88F6281 ix4-200d/
    cat ix4-200d/config_ix4-200d
    ...
    #
    # Feroceon SoC options
    #
    CONFIG_MV88F6281=y
    # CONFIG_JTAG_DEBUG is not set

    #
    # Feroceon SoC Included Features
    #
    CONFIG_MV_INCLUDE_PEX=y
    CONFIG_MV_INCLUDE_USB=y
    CONFIG_MV_INCLUDE_XOR=y
    CONFIG_MV_INCLUDE_CESA=y
    CONFIG_MV_INCLUDE_NAND=y
    CONFIG_MV_INCLUDE_INTEG_SATA=y
    CONFIG_MV_INCLUDE_TDM=y
    CONFIG_MV_INCLUDE_GIG_ETH=y
    # CONFIG_MV_INCLUDE_SPI is not set
    # CONFIG_MV_INCLUDE_SDIO is not set
    # CONFIG_MV_INCLUDE_AUDIO is not set
    # CONFIG_MV_INCLUDE_TS is not set
    # CONFIG_MV_INCLUDE_LCD is not set
    CONFIG_MV_GPP_MAX_PINS=64
    CONFIG_MV_DCACHE_SIZE=0x4000
    CONFIG_MV_ICACHE_SIZE=0x4000
    ...

### U-Boot

    grep -R -i 88F6281 u-boot-3.6/
    find u-boot-3.6/u-boot-3.6.0/board/mv_feroceon/mv_kw/

    cat u-boot-3.6/u-boot-3.6.0/create_all_imagesKW.sh | grep 88f6281 | grep LE

    grep -R -i "Set Power State" u-boot-3.6/

    cat u-boot-3.6/u-boot-3.6.0/board/mv_feroceon/mv_kw/kw_family/ctrlEnv/mvCtrlEnvSpec.h

    /* This enumerator defines the Marvell Units ID      */
    typedef enum _mvUnitId
    {
        DRAM_UNIT_ID,
        PEX_UNIT_ID, // PCI Express
        ETH_GIG_UNIT_ID,
        USB_UNIT_ID,
        IDMA_UNIT_ID, // 	Internal Direct Memory Access
        XOR_UNIT_ID, // 	Marvell XOR engine
        SATA_UNIT_ID,
        TDM_UNIT_ID,
        UART_UNIT_ID,
        CESA_UNIT_ID,
        SPI_UNIT_ID,
        AUDIO_UNIT_ID,
        SDIO_UNIT_ID,
        TS_UNIT_ID,
        LCD_UNIT_ID,
        MAX_UNITS_ID

    }MV_UNIT_ID;