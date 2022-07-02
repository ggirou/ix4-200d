# Get USB key ready

## Format to ext4
    
    # Recreate MBR partition
    sudo apt-get install mbr
    sudo install-mbr /dev/sda

    # Create and formate ext4 partition
    # echo ";" | sudo sfdisk /dev/sda
    sudo parted -l
    sudo parted /dev/sda rm 1
    sudo parted /dev/sda mklabel msdos
    sudo parted -a optimal /dev/sda mkpart primary 0% 100%
    #sudo parted -a minimal /dev/sda mkpart primary 0% 100%
    sudo parted /dev/sda set 1 boot on

    sudo mkfs.ext4 /dev/sda1

    # Optionnal, chek bad blocks and fix it
    sudo badblocks -s -w -t 0 /dev/sda1 > badsectors.txt
    sudo e2fsck -y -l badsectors.txt /dev/sda1

    # Force Regular Filesystem Checks (every 30 mounts or 3 months)
    # https://www.xmodulo.com/automatic-filesystem-checks-repair-linux.html
    sudo tune2fs -c 30 -i 3m /dev/sda1
    sudo tune2fs -l /dev/sda1 | egrep 'Maximum|interval'

## Extract Debian

    sudo mkdir -p /mnt/usb/
    sudo mount /dev/sda1 /mnt/usb/
    sudo tar xzf bullseye-armel.final.tar.gz -C /mnt/usb/
    ls -la /mnt/usb/
    sudo umount /mnt/usb/

> Only boot files:
>
>     sudo tar xzf bullseye-armel.final.tar.gz -C /mnt/usb/ ./boot