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

    cat u-boot-3.6/u-boot-3.6.0/create_all_imagesKW.sh | grep 88f6281 | grep RD | grep LE

    grep -Ri RD_88F6281A_ID u-boot-3.6/

    grep -R -i "Set Power State" u-boot-3.6/

    cat u-boot-3.6/u-boot-3.6.0/board/mv_feroceon/mv_kw/kw_family/boardEnv/mvBoardEnvSpec.h | grep -A 2 -B 2 -P 'RD.88F6281A.(?!PCAC)'

    #define BOARD_ID_BASE           		0x0
    #define RD_88F6281A_ID                          (BOARD_ID_BASE+0x1)

    /* RD-88F6281A */
    #if defined(MV_NAND)
        #define RD_88F6281A_MPP0_7                          0x21111111
    #else
        #define RD_88F6281A_MPP0_7                          0x21112220
    #endif
    #define RD_88F6281A_MPP8_15                     0x00003311
    #define RD_88F6281A_MPP16_23                    0x33331100
    #define RD_88F6281A_MPP24_31                    0x33003333
    #define RD_88F6281A_MPP32_39                    0x00000533
    #define RD_88F6281A_MPP40_47                    0x00000000
    #define RD_88F6281A_MPP48_55                    0x00000000
    #define RD_88F6281A_OE_LOW                      0xfffccfff
    #define RD_88F6281A_OE_HIGH                     0x0000000f
    #define RD_88F6281A_OE_VAL_LOW                0x00033000
    #define RD_88F6281A_OE_VAL_HIGH                  0x0

    cat u-boot-3.6/u-boot-3.6.0/board/mv_feroceon/mv_kw/kw_family/boardEnv/mvBoardEnvSpec.c | grep -A 2 -B 2 -P 'RD.88F6281A.(?!PCAC)'

    #define RD_88F6281A_BOARD_PCI_IF_NUM            0x0
    #define RD_88F6281A_BOARD_TWSI_DEF_NUM          0x2
    #define RD_88F6281A_BOARD_MAC_INFO_NUM          0x2
    #define RD_88F6281A_BOARD_GPP_INFO_NUM          0x5
    #define RD_88F6281A_BOARD_MPP_GROUP_TYPE_NUM    0x1
    #define RD_88F6281A_BOARD_MPP_CONFIG_NUM                0x1
    #if defined(MV_NAND) && defined(MV_NAND_BOOT)
        #define RD_88F6281A_BOARD_DEVICE_CONFIG_NUM     0x1
    #elif defined(MV_NAND) && defined(MV_SPI_BOOT)
        #define RD_88F6281A_BOARD_DEVICE_CONFIG_NUM     0x2
    #else
        #define RD_88F6281A_BOARD_DEVICE_CONFIG_NUM     0x1
    #endif
    #define RD_88F6281A_BOARD_DEBUG_LED_NUM         0x0
    #define RD_88F6281A_BOARD_NAND_READ_PARAMS                  0x003e07cf
    #define RD_88F6281A_BOARD_NAND_WRITE_PARAMS                 0xf0f0f
    #define RD_88F6281A_BOARD_NAND_CONTROL                  0x01c7d943

    MV_BOARD_GPP_INFO rd88f6281AInfoBoardGppInfo[] = 
        /* {{MV_BOARD_GPP_CLASS	devClass, MV_U8	gppPinNum}} */
        {{BOARD_GPP_SDIO_DETECT, 28},
        {BOARD_GPP_USB_OC, 29},
        {BOARD_GPP_WPS_BUTTON, 35},
        //{BOARD_GPP_MV_SWITCH, 38},
        {BOARD_GPP_USB_VBUS, 49}
        };

    MV_BOARD_MPP_INFO       rd88f6281AInfoBoardMppConfigValue[] = 
            {{{
            RD_88F6281A_MPP0_7,
            RD_88F6281A_MPP8_15,
            RD_88F6281A_MPP16_23,
            RD_88F6281A_MPP24_31,
            RD_88F6281A_MPP32_39,
            RD_88F6281A_MPP40_47,
            RD_88F6281A_MPP48_55
            }}};

    MV_BOARD_INFO rd88f6281AInfo = {
            "RD-88F6281A",                          /* boardName[MAX_BOARD_NAME_LEN] */
            RD_88F6281A_BOARD_MPP_GROUP_TYPE_NUM,           /* numBoardMppGroupType */
            rd88f6281AInfoBoardMppTypeInfo,
            RD_88F6281A_BOARD_MPP_CONFIG_NUM,               /* numBoardMppConfig */
            rd88f6281AInfoBoardMppConfigValue,
            0,                                              /* intsGppMaskLow */
            (1 << 3),                                       /* intsGppMaskHigh */
            RD_88F6281A_BOARD_DEVICE_CONFIG_NUM,            /* numBoardDevIf */
            rd88f6281AInfoBoardDeCsInfo,
            RD_88F6281A_BOARD_TWSI_DEF_NUM,                 /* numBoardTwsiDev */
            rd88f6281AInfoBoardTwsiDev,
            RD_88F6281A_BOARD_MAC_INFO_NUM,                 /* numBoardMacInfo */
            rd88f6281AInfoBoardMacInfo,
            RD_88F6281A_BOARD_GPP_INFO_NUM,                 /* numBoardGppInfo */
            rd88f6281AInfoBoardGppInfo,
            RD_88F6281A_BOARD_DEBUG_LED_NUM,                        /* activeLedsNumber */              
            NULL,
            0,                                                                              /* ledsPolarity */
            RD_88F6281A_OE_LOW,                             /* gppOutEnLow */
            RD_88F6281A_OE_HIGH,                            /* gppOutEnHigh */
            RD_88F6281A_OE_VAL_LOW,                         /* gppOutValLow */
            RD_88F6281A_OE_VAL_HIGH,                                /* gppOutValHigh */
            0,                                              /* gppPolarityValLow */
            BIT6,                                           /* gppPolarityValHigh */
            NULL,
            //rd88f6281AInfoBoardSwitchInfo,                        /* pSwitchInfo */
        RD_88F6281A_BOARD_NAND_READ_PARAMS,
        RD_88F6281A_BOARD_NAND_WRITE_PARAMS,
        RD_88F6281A_BOARD_NAND_CONTROL
    };


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

    cat u-boot-3.6/u-boot-3.6.0/board/mv_feroceon/mv_hal/gpp/mvGppRegs.h

    #define GPP_DATA_OUT_REG(grp)			((grp == 0) ? 0x10100 : 0x10140)
    #define GPP_DATA_OUT_EN_REG(grp)		((grp == 0) ? 0x10104 : 0x10144)
    #define GPP_BLINK_EN_REG(grp)			((grp == 0) ? 0x10108 : 0x10148)
    #define GPP_DATA_IN_POL_REG(grp)		((grp == 0) ? 0x1010C : 0x1014c)
    #define GPP_DATA_IN_REG(grp)			((grp == 0) ? 0x10110 : 0x10150)
    #define GPP_INT_CAUSE_REG(grp)			((grp == 0) ? 0x10114 : 0x10154)
    #define GPP_INT_MASK_REG(grp)			((grp == 0) ? 0x10118 : 0x10158)
    #define GPP_INT_LVL_REG(grp)			((grp == 0) ? 0x1011c : 0x1015c)

    #define GPP_DATA_OUT_SET_REG			0x10120
    #define GPP_DATA_OUT_CLEAR_REG			0x10124
