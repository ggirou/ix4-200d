ix4-200d stock firmware
-----------------------

# Download original firmware

    wget http://download.lenovo.com/nasupdate/iomnas/ix4-200d-3.2.16.30221.tgz
    openssl enc -d -md md5 -aes-128-cbc -in "ix4-200d-3.2.16.30221.tgz" -k "EMCNTGSOHO" -out "ix4-200d-3.2.16.30221-decrypted.tar.gz"
    tar xzf ix4-200d-3.2.16.30221-decrypted.tar.gz -C ./ix4-200d-3.2.16.30221/

## Few experiments

Mount `apps` filesystem:

    cd ix4-200d-3.2.16.30221/
    mkdir apps.mnt
    sudo mount apps apps.mnt/

Extract kernel:

    dumpimage -l zImage
    dumpimage -i zImage kernel.extracted

# Backup firmware

Nand stock mtdparts:

    0x00000000-0x000a0000 : "uboot" (size: 0xa0000)
    0x000a0000-0x000b0000 : "env" (size: 0x10000)
    0x000b0000-0x002d4000 : "zImage" (size: 0x224000)
    0x002d4000-0x004f8000 : "initrd" (size: 0x224000)
    0x00000000-0x02000000 : "flash" (size: 0x02000000)

## From u-boot

Boot from serial with new u-boot (ext4write command enabled)

    kwboot -p -t -B 115200 /dev/ttyUSB0 -b ix4-200d-u-boot-2022.04.kwb

### Partition dump

    usb start
    nand read 0x1000000 0x0 0xa0000
    ext4write usb 0:1 0x1000000 /nand-0-uboot.bin 0xa0000
    nand read 0x1000000 0x000a0000 0x10000
    ext4write usb 0:1 0x1000000 /nand-1-env.bin 0x10000
    nand read 0x2000000 0x000b0000 0x224000
    ext4write usb 0:1 0x2000000 /nand-2-zImage.bin 0x224000
    nand read 0x3000000 0x002d4000 0x224000
    ext4write usb 0:1 0x3000000 /nand-3-initrd.bin 0x224000

### Full dump

    => usb start

    => nand read 0x1000000 0x0

    NAND read: device 0 whole chip
    size adjusted to 0x1fe8000 (6 bad blocks)
    Skipping bad block 0x01008000
    Skipping bad block 0x01340000
    Skipping bad block 0x01670000
    Skipping bad block 0x018c0000
    Skipping bad block 0x01980000
    Skipping bad block 0x01f10000
    33456128 bytes read: OK

    # Adapt the last number with the size read by nand command (may be less)
    => ext4write usb 0:1 0x1000000 /nand.bin 0x02000000

## From debian

    sudo dd if=/dev/mtd0 of=mtd0.bin bs=1M
    sudo dd if=/dev/mtd1 of=mtd1.bin bs=1M
    sudo dd if=/dev/mtd2 of=mtd2.bin bs=1M
    sudo dd if=/dev/mtd3 of=mtd3.bin bs=1M
    cat mtd0.bin mtd1.bin mtd2.bin mtd3.bin > mtd.bin
