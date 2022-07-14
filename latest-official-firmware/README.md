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

# Boot u-boot and debian from USB key

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

    # Copy kernel and initrd images
    sudo mkdir -p /mnt/usb/
    sudo mount /dev/sda1 /mnt/usb/
    sudo cp zImage initrd /mnt/usb/
    ls -la /mnt/usb/
    sudo umount /mnt/usb/

## Serial boot u-boot

    kwboot -p -t -B 115200 /dev/ttyUSB0 -b u-boot-DRAM256-MapowerV5.1_nand.bin

> Hit `Ctrl+C` to stop boot process.

    usb start
    ext2ls usb 0 /
    ext2load usb 0:1 0x2000000 zImage
    ext2load usb 0:1 0x4500000 initrd

    # WIP