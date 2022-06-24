
# Backup firmware

Source: https://cybergibbons.com/hardware-hacking/recovering-firmware-through-u-boot/

Install TFTP on a debian:

    sudo apt install tftpd-hpa
    ifconfig eth0

Run commands in Marvell prompt:

    nand read 0x82000000 0x0 0x2000000
    setenv ipaddr 192.168.1.250
    setenv serverip 192.168.1.48
    # Tftp upload not available :(
    # tftp 0x82000000 firmware.bin 0x2000000