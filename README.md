Run Debian on ix4-200d
----------------------

Everything here comes essentially from:

  - https://forum.doozan.com/read.php?2,22623

> **DISCLAIMER NOTICE**
> * I'm not responsible for bricked devices, dead SD cards, thermonuclear war, or you getting fired because the alarm app failed (like it did for me...).
> * YOU are choosing to make these modifications, and if you point the finger at me for messing up your device, I will laugh at you.
> * Your warranty will be void if you tamper with any part of your device / software.
> 😘


# Serial boot

![Serial pinout](serial.jpg)

Serial: 115200 baud 3.3v:

    CN4
    --------------
    |  9 8 6 4 2 |
    | 10 7 5 3 1 |
    -------------- PIN 1 Mark (fat line)


    1 = TXD <--> RXD of USB Adapter
    4 = RXD <--> TXD of USB Adapter
    6 = GND <--> GND of USB Adapter
    10 = 3.3v

Open TTY with `screen`:

    screen -L /dev/ttyUSB0 115200

> Hint: press `ctrl + a` then type `:quit` to quit.

Start your device and press any key until `Hit any key to stop autoboot` is displayed. You should see u-boot prompt:

    Marvell>>

First, keep current u-boot parameters:

    printenv

> Keep the content of `printenv` [output](stock-firmware/uboot-printenv.txt). This will be a useful reference if you want to restore any u-boot parameters.

# Test new U-Boot with Serial port

    # You may need to build latest kwboot
    sudo apt-get install u-boot-tools

    kwboot -p -t -B 115200 /dev/ttyUSB0 -b shivaplug-u-boot-2022.04.kwb

> Hint: press `ctrl + \` then type `c` to quit.

> If you got the following error, you need to use the latest version of kwboot, build it [from u-boot sources](u-boot/README.md):
>
>     Sending boot message. Please reboot the target...-
>     Sending boot image...
>     0 % [+xmodem: Protocol error
