ix4-200d
--------

Everything here comes essentially from:

  - TODO

> **DISCLAIMER NOTICE**
> * I'm not responsible for bricked devices, dead SD cards, thermonuclear war, or you getting fired because the alarm app failed (like it did for me...).
> * YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you.
> * Your warranty will be void if you tamper with any part of your device / software.
> 😘


# Serial boot

![Serial pinout](serial.jpg)

    screen -L /dev/ttyUSB0 115200

Start your device and press any key until `Hit any key to stop autoboot` is displayed. You should see u-boot prompt:

    Marvell>>

# Get USB key ready

## Format to ext2
    
    # Recreate MBR partition
    sudo apt-get install mbr
    sudo install-mbr /dev/sda

    # Create and formate ext2 partition
    # echo ";" | sudo sfdisk /dev/sda
    sudo parted -l
    sudo parted /dev/sda rm 1
    sudo parted /dev/sda mklabel msdos
    sudo parted -a optimal /dev/sda mkpart primary 0% 100%
    #sudo parted -a minimal /dev/sda mkpart primary 0% 100%
    sudo parted /dev/sda set 1 boot on

    sudo mkfs.ext2 /dev/sda1

    # Optionnal, chek bad blocks and fix it
    sudo badblocks -s -w -t 0 /dev/sda1 > badsectors.txt
    sudo e2fsck -y -l badsectors.txt /dev/sda1

    # Force Regular Filesystem Checks (every 30 mounts or 3 months)
    # https://www.xmodulo.com/automatic-filesystem-checks-repair-linux.html
    sudo tune2fs -c 30 -i 3m /dev/sda1
    sudo tune2fs -l /dev/sda1 | egrep 'Maximum|interval'

