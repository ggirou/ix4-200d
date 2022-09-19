General LSP information
=================================================

Contents:
---------
  1.  Default kernel configuration
  2.  Marvell LSP File locations
  3.  Procedure for Porting a new Customer Board (KW)
  4.  MTD (Memory Technology Devices) Support
  5.  Network
    5.1 mv_gateway driver 
    5.2 eth-tool
  6. TDM
  7.  SATA
    7.1 SCSI scattered spin-up support 
  8.  USB in HOST mode
  9.  USB in Device mode
  10. Real Time Clock
  11. CESA
  12. SD\MMC\SDIO
  13. Audio
  14. Kernel configuration
    14.1 General Configuration
    14.2 Run-Time Configuration
    14.3 Compile-Time Configuration 
  15. Debugging  Tools
  16. CPUFREQ
  17. UBIFS
  18. Dual CPU Support for MV78200 SoC
  19. LCD




1.  Default kernel configuration
---------------------------------

	Board			Default Configuration
==========================================================================================
	DB-88F6282-BP-A		mv_kw_defconfig
	RD-88F6282-A		mv_kw_gw_defconfig
	DB-88F6281-BP-A	        mv_kw_defconfig 	
	DB-88F6192-BP-A	(6190)	mv_kw_defconfig 
	DB-88F6180-BP-A		mv_kw_defconfig 
	RD-88F6281-A		mv_kw_gw_defconfig 
	RD-88F6192-A (6190)	mv_kw_defconfig 


2.  Marvell LSP File locations
-------------------------------
    o  core directory: 
       - /arch/arm/mach-feroceon-xx/...
       - /include/asm-arm/arch-feroceon-xx/...

    o drivers:  
       - /arch/arm/plat-feroceon/...


3.  Procedure for Porting a new Customer Board (relevant only for KW)
-----------------------------------------------
The following are the steps for porting a new customer board to the Marvell LSP:

    o Add the Board Specific configuration definitions:
	File location: ~/arch/arm/mach-feroceon-kw/kw_family/boardEnv/mvBoardEnv.h

	- MPP pin configuration. Each pin is represented by a nible. Refer the
	  SoC Datasheet for detailed information about the options and values
	  per pin.

	- MPP pin direction (input or output). Each MPP pin is represented
	  with a single bit (1 for input and 0 for output).

	- MPP pin level (default level, high or low) if the MPP pin is a GPIO
	  and configured to output.

	- Specify the Board ID. This is need to identify the board. This is
	  supposed to be synchronized with the board ID passed by the UBoot.

    o Add the Board Specific configuration tables:
	File location: ~/arch/arm/mach-feroceon-kw/kw_family/boardEnv/mvBoardEnv.c

	The following configuration options are listed in the order they are
	present in the "MV_BOARD_INFO" structure.

	- boardName: Set the board name string. This is displayed by both Uboot and Linux
	  during the boot process.

	- pBoardMppConfigValue (MV_BOARD_MPP_INFO): This structure arranges the MPP pins
	  configuration. This is usually not modified.

	- intsGppMask: Select MPP pins that are supposed to operate as
	  interrupt lines.

	- pDevCsInfo (MV_DEV_CS_INFO):Specify the devices connected on the device bus 
	  with the Chip select configuration.

	- pBoardPciIf (MV_BOARD_PCI_IF): This is the PCI Interface table with the PCI 
	  device number and MPP pins assigned for each of the 4 interrupts A, B, C and D.

	- pBoardTwsiDev (): List of I2C devices connected on the TWSI
	  interface with the device ID Addressing mode (10 or 7 bit).

	- pBoardMacInfo (MV_BOARD_MAC_INFO): Specifies the MAC speed and the Phy address
  	  per Ethernet interface.

	- pBoardGppInfo (): List of MPP pins configured as GPIO pins with special functionality.

	- pLedGppPin (MV_U8): array of the MPP pins connected to LEDs.

	- ledsPolarity: Bitmap specifying the MPP pins to be configured with
	  reverse polarity.

	- gppOutEnVal: This is usually defined in the mvCustomerBoardEnv.h
	  specifying the direction of all MPP pins.

	- gppPolarityVal: Not used.

	Finally update all of the configuration table sizes (xxxxxxxxx_NUM definitions)
  	according to the number of entries in the relevant table.

    o  Specify the memory map of your new board. 
	File location: ~/arch/arm/mach-feroceon-kw/sysmap.c

	The following configurations should be done:
	- Look for the section in the file related to the SoC device you are using.

	- Add a new table with Address Decoding information (MV_CPU_DEC_WIN) for your board.
	  (Usually existing address decoding tables are compatible with most boards, the 
	  changes might be only in the Device Chip selects only).

	- In the function "mv_sys_map()", add a new "case:" statement (under the appropriate 
	  SoC type) with the your newly added board ID mapping it to the appropriate Address 
	  Decoding configuration table.


4.  MTD (Memory Technology Devices) Support
--------------------------------------------

A new MTD map driver has been added, this driver automatically detects the existing Flash devices
and mapps it into the Linux MTD subsystem. This new driver affect NOR flashes (CFI, SPI and Marvell). 
NAND flashes are supported separately and not not part of this driver.

The detection of MTD devices depends on the Linux kernel configuration options set (using the 
"make menuconfig" or "make xconfig" tools).
To have basic MTD Support the following options should be selected:
	-> Device Drivers                                                                                                   
          -> Memory Technology Devices (MTD)                                                                                
            -> Memory Technology Device (MTD) support (MTD [=y])                                                            

For CFI Flashes the following options should be selected
	-> Device Drivers                                                                                                   
          -> Memory Technology Devices (MTD)                                                                                
            -> Memory Technology Device (MTD) support (MTD [=y])                                                            
              -> RAM/ROM/Flash chip drivers 
		-> Detect flash chips by Common Flash Interface (CFI) probe

For Intel (and Intel compatible) Flashes the following options should be selected
	-> Device Drivers                                                                                                   
          -> Memory Technology Devices (MTD)                                                                                
            -> Memory Technology Device (MTD) support (MTD [=y])                                                            
              -> RAM/ROM/Flash chip drivers 
		-> Support for Intel/Sharp flash chips

For AMD (and AMD compatible) Flashes the following options should be selected
	-> Device Drivers                                                                                                   
          -> Memory Technology Devices (MTD)                                                                                
            -> Memory Technology Device (MTD) support (MTD [=y])                                                            
              -> RAM/ROM/Flash chip drivers 
		->  Support for AMD/Fujitsu flash chips

By default, the map driver maps the whole flash device as single mtd device (/dev/mtd0, /dev/mtd1, ..)
unless differently specified from the UBoot using the partitioning mechanism.
To use the flash partitioning you need to have this option selected in the kernel. To do this
you will need the following option selected:
 	-> Device Drivers                                                                                                   
          -> Memory Technology Devices (MTD)                                                                                
            -> Memory Technology Device (MTD) support (MTD [=y])   
	      -> MTD concatenating support

The exact partitioning is specified from the UBoot arguments passed to the kernel. The following 
is the syntax of the string to be added to the UBoot "booatargs" environment variable:
    
       'mtdparts=<mtd-id>:7m@0(rootfs),1m@7(uboot)ro' 
       where <mtd-id> can be one of options: 
       1) M-Flash => "marvell_flash"
       2) SPI-Flash => "spi_flash"
       3) NOR-Flash => "cfi_flash"

The latest release of the mtd-utils can be downloaded from http://www.linux-mtd.infradead.org.
(The main page has a link to the latest release of the mtd-utils package).
This package provides a set of sources that can be compiled and used to manage and debug MTD devices. 
These tools can be used to erase, read and write MTD devices and to retrieve some basic information.

The following is a list of useful commands:
To see a list of MTD devices detect by the kernel: "cat /proc/mtd"
To erase the whole MTD device: "./flash_eraseall /dev/mtd0"
To erase the whole MTD device and format it with jffs2: "./flash_eraseall -j /dev/mtd1"
To get device info (sectors size and count): "./flash_info /dev/mtd1"
To create jffs2 image for NAND flash(with eraseblock size 0x20000): 
           ./mkfs.jffs2 -l -e 0x20000 -n -d <path_to_fs> -o <output_file>

for NOR flash only:
===================
To protect all sectors: "./flash_lock /dev/mtd1 0x0 -1"
To unprotect all sectors: "./flash_unlock /dev/mtd1"

  NAND ECC:
  ========
  The Linux support 1 bit SW ECC protection.
  This release include support for 4 bit SW ECC Reed Solomon.
  To enable this support set the relevant config under the feroceon MTD options and configure 
  the U-Boot to use 4 bit ECC by setting the nandEcc env var to 4bit.

5. network
----------  

  5.1 mv_gateway driver
---------------------

    o  Supported SoC: 88F6281, 88F6183. 
       Supported switch: 88E6165, 88E6161. 
       Used for platforms with switch device on board (RD platforms).

    o  Interface name - "eth<port>", port starts from 1. eth0 is reserved for the GbE port 
       connected directly to a PHY.

    o  Multiple VLANs/network-interface management.
       Configuration in kerenl command line -
       Sysntax: mv_net_config=(<mac-addr>,<port-list>)(...),mtu=<mtu-value>
       e.g. mv_net_config=(00:aa:bb:cc:dd:ee,0)(00:11:22:33:44:55,1:2:3:4),mtu=1500

    o  IP ToS based QoS
       -  VoIP QoS
       -  Routing

    o  L2 IGMP snooping support

    o  Packets between the CPU and the Switch are controlled with Marvell Header

    o  Link status indication implemented using an ISR connected to the switch interrupt line 

    o  See ~/arch/arm/plat-feroceon/mv_drivers_lsp/mv_network/mv_ethernet/

  5.2 Ethtool support
  -----------------------
  This release introduces support for a standard ethtool. 
  Please note that for non-raw registers dump command the latest ethtool user space utility with Marvell patches is needed.

  The ethtool support should be enabled in kernel configuration:
   CONFIG_MV_ETH_TOOL:                                                                                                        
   -> System Type
     -> Feroceon SoC options  
       -> SoC Networking support 
         -> Networking Support
            -> Control and Statistics               

  The following ethtool commands are supported in current release:

  - ethtool DEVNAME                               Display standard information about device

  - ethtool -s |--change DEVNAME             Change generic options
            [ speed 10|100|1000 ]
            [ duplex half|full ]
            [ autoneg on|off ]

  - ethtool -c|--show-coalesce DEVNAME     Show coalesce options

  - ethtool -C|--coalesce DEVNAME             Set coalesce options
            [rx-usecs N]
            [tx-usecs N]

  - ethtool -i|--driver DEVNAME                    Show driver information

  - ethtool -d|--register-dump DEVNAME       Do a register dump
            [ raw on|off ]

  - ethtool -r|--negotiate DEVNAME              Restart N-WAY negotation

  - ethtool -p|--identify DEVNAME                Show visible port identification (e.g. blinking)
            [ TIME-IN-SECONDS ]

  - ethtool -S|--statistics DEVNAME             Show adapter statistics

14. TDM
-------

Depending on board setup, the UBoot mvPhoneConfig environment parameter should be configured as following:
For 2xFXS:               setenv mvPhoneConfig=mv_phone_config=dev[0-1]:fxs
For 1xFXS + 1xFXO:  setenv mvPhoneConfig=mv_phone_config=dev[0]:fxs, dev[1]:fxo

After boot process is completed, phone_test.ko module is required in order to run various voice tests.
This module contains the following tests:
1 - Self echo on `line0_id`
2 - Loopback between 2 FXS ports(line0_id & line1_id)
3 - Loopback between FXS and FXO ports(line0_id & line1_id respectively)
4 - Ring on FXS line `line0_id`
5 - Generate SW tones(300Hz, 630Hz, 1000Hz) on FXS line `line0_id`

For example, to run loopback test between 2 phones, run the following command:
insmod phone_test.ko line0_id=0 line1_id=1 test_id=2

In order to run different test, unload the module using the standard Linux `rmmod` command and reload the module with the requested `test_id` parameter

7. SATA 
---------

The LSP includes a full driver for Marvell's SATA controllers, the following is a list of the 
devices supported:
	- Integrated Sata Controller (in 88F5182, 88F6082, 88F6082L, 88F5082)
	- 88SX5041
	- 88SX5080
	- 88SX5081
	- 88SX6081
	- 88SX6041
	- 88SX6042
	- 88SX7042

The driver HAL APIs are found under: ~/arch/arm/mach-feroceon/Board/SATA/
The Linux driver is found under: ~/arch/arm/plat-feroceon/mv_drivers_lsp/mv_sata/
To enable supporting Optical disk drives (CD-ROM/DVD-ROM), this option should be selected:
 	-> System Type                                                                                                       
          -> Feroceon SoC options                                                                                            
            -> Support for Marvell Sata Adapters (SCSI_MVSATA [=y])                                                          
              -> Sata options                                                                                                
                -> Support ATAPI (CD-ROM/DVD-ROM) devices

The SATA driver has basic debugging capabilities. Using the kernel configuration tools, the user
can select 1 of 2 debugging options:
	- Display log messages on error conditions.
	- Display complete debugging log.


The SATA kernel configuration options are found under:
 	-> System Type                                                                                                       
          -> Feroceon SoC options                                                                                            
            -> Support for Marvell Sata Adapters (SCSI_MVSATA [=y])                                                          
              -> Sata options                                                                                                
                -> Debug level (<choice> [=y]) 

Besides, the SATA driver provides a runtime mechanism using the /proc filesystem to display 
all information about detected controllers and Disks.
The command "cat /proc/scsi/mvSata/0" where "0" specified the SATA channel number requested. The
channel numbers range from 0 to n where n is the one minus the number of channels available on the
detected SATA controller.

Partial hdparm utility support was added, commands supported by this LSP are:
	- hdparm -S [device] : to set standby (spindown) timeout
	- hdparm -y [device] : to put drive in standby mode
	- hdparm -Y [device] : to put drive to sleep

  Obselete: 
This driver supports the ATA SMART commands that issued by the smartmontools tool, version 5.36 
or later of that tool needed, also, the user should add "-d marvell" to the commands line parameters.

  Please use hdparm or sdparm instead!!


  7.1 SCSI scattered spin-up support
  ----------------------------------
    Hard drive spin-up was always the highest power consuming stage. Embedded devices mostly use low 
    power suppliers that sometimes needs to drive numerous hard drives.
    This feature developed in order to prevent the power supply's overloading when numerous hard drives spin-up.

    Usage
      Apply the scattered spin-up kernel patch.
      Compile the kernel with the config CONFIG_MV_SCATTERED_SPINUP enabled.

      Pass the following parameter in the kernel line: 
      spinup_config=<spinup_max>,<spinup_timeout
      For example: spinup_config=2,6 will config the module for 2 maximum disks spinning-up with 6 seconds timeout. 
      Parameters explanation:
	1.      <spinup_max> - The maximum spinning-up disks(can be between 1 and 8)  will be like this: 
	      0 = feature off. 
	      1 - 8 = number of disks 
	      <0,>8 = invalid parameter (will behave like feature off) 
	2.      <spinup_timeout> - The spin-up timeout (can be between 1 and 6) will be like this: 
	      0 = feature off. 
	      1 - 6 = in seconds 
	      <0,>6 = invalid parameter (will behave like feature off) 
	Any parsing error will cause an invalid parameters print and will behave as feature off. 

    EXPERIMANTAL kernel config:
    CONFIG_MV_DISKS_POWERUP_TO_STANDBY - on boot initialization all hard drives will assume to be in standby.


8.  USB in HOST mode
---------------------

The mode of the USB controller (device or host) is configured using the UBoot environment variables. 
To work in USB HOST mode, set the UBoot variable "usb0Mode"/"usb1Mode" to "host".
The USB driver uses the standart Linux ehci driver.


9. USB in Device mode
----------------------

To work in device mode, the UBoot environment variable "usb0Mode" should be set to "device". 
In order to operate as "Mass Storage Device" the following steps should be followed:
	- Prepare a file to be used as the storage back end (for example use the command 
          "dd bs=1M count=64 if=/dev/zero of=/root/diskFile" to create a file of size 64M.)
	- Insert the Marvell USB gadget driver: "insmod mv_udc.ko"
	- Insert the file storage driver: "insmod g_file_storage.ko file=/root/diskFile". If 
	  the backing file was created on an NFS drive then the following command should be used
          instead: "insmod g_file_storage.ko file=/root/diskFile use_directio=0"
Note: only one USB interface can be set as a device.


10.  Real Time Clock
---------------------

  The driver is found under ~/arch/arm/mach-feroceon-xx/rtc.c
To read the date and time from the integrated RTC unit, use the command "hwclock".
To set the time in the RTC from the current Linux clock, use the command "hwclock --systohc"


11.  CESA
----------
OpenSSL
-------
  see cesa/openssl/

IPsec
-----
  see cesa/openswan/

Disk encryption 
---------------
o   To create the crypto partition, you are needed to perform the following steps:
    - Create physical partition on the disk - fdisk /dev/sda (example sda1 will created)
    - Create the crypto device example:
     `cryptsetup -c des3_ede -d /share/public/keyfile -s192 create mycryptsda1 /dev/sda1`
    The new device will created /dev/mapper/mycryptsda1 
    - Create the file system on crypto device:
      `mkfs.ext2 /dev/mapper/mycryptsda1 `
    - mount the formatted partition to directory
      `mount /dev/mapper/mycryptsda1 /mnt/mydevice`
    Use the /mnt/mydevice as usual to store your files. All files on the disk will be encrypted.

o   To remove the crypto devices do the following steps:
    - Exit the /mnt/mydevice directory
    - umount /dev/mapper/mycryptsda1
    - cryptsetup remove mycryptsda1


12. SD\MMC\SDIO (not relevant for DD)
----------------
This driver is enabled in KW SoCs that include an SD\MMC\SDIO host. the 
driver is based on latest mmc driver from kernel 2.6.24.

o  creating mmc block devices:

# mknod /dev/mmcblk b 179 0
# mknod /dev/mmcblk1 b 179 1
# mknod /dev/mmcblk2 b 179 2
# mknod /dev/mmcblk3 b 179 3
..
..
..

o  modules:
# insmod mvsdmmc.ko
o debug parameters under /proc/mvsdmmc
o mvsdmmc.ko parameters:


highspeed -     1 - support highspeed cards (default)
                0 - don't support highspeed cards

maxfreq         value - maximum frequency supported (default 50000000)

dump_on_error	if 1 then on error dumps registers values

detect		1 - support GPIO detection interrupt
		0 - no support for GPIO detection interrupt


13. Audio
---------
o requires ALSA lib and ALSA utils version 1.0.14 
o snddevices script should be run if Alsa device doesn't exist.

14. Kernel configuartion
-------------------------

 14.1 General Configuration:
 ---------------------------
- This release has support for sending requests with length up to 1MB for the
  SATA drives, in some cases, this feature can reduce the system performance,
  for example, running Samba and a client that performs sequential reads.
  Note that the user can modify the limit of the max request using the sysfs,
  this parameter is per block device, and it's defined by special file called
  'max_sectors_kb' under the queue directory of the block device under the sysfs.
  for example, the /sys/block/sda/queue/max_sectors_kb is for the /dev/sda
  device.

- In order to use block devices that are larget then 2TB, CONFIG_LBD should be enabled.
  fdisk doesn't support block devices that are larger then 2TB, instead 'parted' should be used.
  The msdos partition table doesn't support >2TB , you need GPT support by the kernel:
  File Systems
    Partition Types
      [*] Advanced partition selection
      [*] EFI GUID Partition support

 14.2 Run-Time Configuration:
 ----------------------------
  The following features can be configured during run-time:
    o  NFP mechanism:
  	 echo D > /proc/net/mv_eth_tool (disable NFP)
  	 echo E > /proc/net/mv_eth_tool (enable NFP)
    o TX enable race:
         mv_eth_tool -txen <port> 0/1 (0 - disable, 1 - enable)         
    o SKB reuse mechanism:
         mv_eth_tool -skb 0/1 (0 - disable, 1 - enable)
    o LRO support:
	 mv_eth_tool -lro <port> 0/1 (0 - disable, 1 - enable)
         
  * for more ethernet run-time configurations, see egigatool help.
  
 14.3 Compile-Time Configuration:
 --------------------------------
 The following features can be configured during compile-time only:   
    o L2 cache support
    o XOR offload for CPU tasks:
       - memcpy
       - copy from/to user
       - RAID5 XOR calculation
    o TSO
    o Multi Q support - for mv_gateway driver only.
    o CESA test tool support.   


15.  Debugging  Tools
----------------------

    o  Runtime debugging is supported through the /proc virtual FS.
       See ~/arch/arm/mach-feroceon-xx/proc.c

    o  mv_shell: Access memory, SoC registers, and SMI registers from user space.
       mv_eth_tool: Probe mv_ethernet driver for statistic counters.
       mv_cesa_tool: Probe CESA driver for statistic counters.
       These tools are found under ~/tools

    o The LSP supports kernel debugging using KGDB. Refer to AN232 "Using GDB to Debug the 
      Linux Kernel and Applications" for detailed information.

    o Early boot debugging is supported by the LSP. To enable this option configure the following
      settings in the kernel.
	-> Kernel hacking
	  -> Kernel low-level debugging functions
      You have this option you need first to enable the "Kernel debugging" tab first.
  
      
16. CPUFREQ (relevant only for KW)
------------

 16.1 Introduction:
 ------------------
   The cpufreq driver allows the cpu frequency to be adjusted either manually from userspace or
   automatically according to given policies. The available policies are defined when the kernel
   is configured. In order to get/set cpu frequency parameters the cpufreq utils are used.

 16.2 cpufreq kernel driver:
 -------------------------
   The driver implements power save on/off according to the desired cpu frequency.      

 16.3 kernel configuration:
 --------------------------
	- Enable Cpu Frequency scaling and choose userspace governor as default governor
	- Choose Default CPUFreq governor: userspace

	CONFIG_CPU_FREQ=y
	CONFIG_CPU_FREQ_TABLE=y
	# CONFIG_CPU_FREQ_DEBUG is not set
	CONFIG_CPU_FREQ_STAT=y
	# CONFIG_CPU_FREQ_STAT_DETAILS is not set	
	# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
	CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
	CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
	# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set
	CONFIG_CPU_FREQ_GOV_USERSPACE=y
	# CONFIG_CPU_FREQ_GOV_ONDEMAND is not set
	# CONFIG_CPU_FREQ_GOV_CONSERVATIVE is not set
	CONFIG_CPU_FREQ_FEROCEON_KW=y




 16.4 cpufrequtils installation:
 -------------------------------
   On a debian system it suffices to say:
   apt-get install cpufrequtils
	

 16.5 Using the cpufreq utilties:
 --------------------------------
   -Display information:
	% cpufreq-info -h

	cpufrequtils 004: cpufreq-info (C) Dominik Brodowski 2004-2006	
	Report errors and bugs to cpufreq@lists.linux.org.uk, please.
	Usage: cpufreq-info [options]
	Options:
	  -c CPU, --cpu CPU    CPU number which information shall be determined about
	  -e, --debug          Prints out debug information
	  -f, --freq           Get frequency the CPU currently runs at, according
	                       to the cpufreq core *
	  -w, --hwfreq         Get frequency the CPU currently runs at, by reading
	                       it from hardware (only available to root) *
	  -l, --hwlimits       Determine the minimum and maximum CPU frequency allowed *
	  -d, --driver         Determines the used cpufreq kernel driver *
	  -p, --policy         Gets the currently used cpufreq policy *
	  -g, --governors      Determines available cpufreq governors *
	  -a, --affected-cpus  Determines which CPUs can only switch frequency at the
	                       same time *
	  -s, --stats          Shows cpufreq statistics if available
	  -o, --proc           Prints out information like provided by the /proc/cpufreq
	                       interface in 2.4. and early 2.6. kernels
	  -m, --human          human-readable output for the -f, -w and -s parameters
	  -h, --help           Prints out this screen

	If no argument or only the -c, --cpu parameter is given, debug output about
	cpufreq is printed which is useful e.g. for reporting bugs.
	For the arguments marked with *, omitting the -c or --cpu argument is
	equivalent to setting it to zero


	Example Usage:
	% cpufreq-info
	cpufrequtils 004: cpufreq-info (C) Dominik Brodowski 2004-2006
	Report errors and bugs to cpufreq@lists.linux.org.uk, please.
	analyzing CPU 0:
	  driver: kw_cpufreq
	  CPUs which need to switch frequency at the same time: 0
	  hardware limits: 400 MHz - 1.20 GHz
	  available frequency steps: 400 MHz, 1.20 GHz
	  available cpufreq governors: userspace, performance
	  current policy: frequency should be within 400 MHz and 1.20 GHz.
	                  The governor "userspace" may decide which speed to use
	                  within this range.
	  current CPU frequency is 1.20 GHz (asserted by call to hardware).
	  cpufreq stats: 400 MHz:0.00%, 1.20 GHz:0.00%  (6)
 	


   - Setting new cpu frequency:
	% cpufreq-set -h

	cpufrequtils 004: cpufreq-set (C) Dominik Brodowski 2004-2006
	Report errors and bugs to cpufreq@lists.linux.org.uk, please.
	Usage: cpufreq-set [options]
	Options:	
	  -c CPU, --cpu CPU        number of CPU where cpufreq settings shall be modified
	  -d FREQ, --min FREQ      new minimum CPU frequency the governor may select
	  -u FREQ, --max FREQ      new maximum CPU frequency the governor may select
	  -g GOV, --governor GOV   new cpufreq governor
	  -f FREQ, --freq FREQ     specific frequency to be set. Requires userspace
	                           governor to be available and loaded
	  -h, --help           Prints out this screen

	Notes:
	1. Omitting the -c or --cpu argument is equivalent to setting it to zero
	2. The -f FREQ, --freq FREQ parameter cannot be combined with any other parameter
	   except the -c CPU, --cpu CPU parameter
	3. FREQuencies can be passed in Hz, kHz (default), MHz, GHz, or THz
	   by postfixing the value with the wanted unit name, without any space
	   (FREQuency in kHz =^ Hz * 0.001 =^ MHz * 1000 =^ GHz * 1000000).


	Example usage:

	% cpufreq-set -f 1.2GHz
	% cpufreq-set -f 400MHz
	


 16.6 Dynamic Frequency Scaling
 ------------------------------
   It is possible to let a background daemon (e.g. hald-addon-cpufreq) decide how to
   scale the cpu frequency according to the system load. For this purpose proceed as follows:
	- Configure kernel with "ondemand" governor.
	- Set the default governor to be "userspace".
	- The governor can also be set from userspace by "cpufreq-set -g"

	- The behaviour of the hald-addon-cpufreq daemon can be configured through sysfs at
	% ls /sys/devices/system/cpu/cpu0/cpufreq/ondemand/
	  ignore_nice_load  sampling_rate      sampling_rate_min
           powersave_bias    sampling_rate_max  up_threshold		


17. UBIFS
----------

  17.1 Getting the sources:
  -------------------------
	- mtd utils with ubifs support: git://git.infradead.org/mtd-utils.git
	
  17.2 Compiling mtd utils:
  -------------------------

	The mtd utils have to be compiled both for arm and for x86 since typically the
	file system will be generated on a x86 system.
	The lzo and uuid libraries are needed for compiling and for running the ubi utilities.

  17.3 UBI utilities on the target system:
  ----------------------------------------

	The following utilities should be on the target system:
	- ubiformat, ubinfo, ubimkvol, ubirmvol, ubiupdatevol, ubiattach, ubidetach


  17.4 Building a ubifs root file system:
  ---------------------------------------

	- In the following I assume that the root file system is situated in the directory rootfs.
 	  Several of the parameters 
  	  appearing in the following example need to be adjusted to the user's needs and only serve as examples.

	- Create a configuration file ubinize.cfg with the following contents:

	[ubifs]
	mode=ubi
	image=tmp_rootfs.img
	vol_id=0
	vol_size=90MiB
	vol_type=dynamic
	vol_name=rootfs
	vol_flags=autoresize	


	- Execute the following commands:

  	% mkfs.ubifs -g 2 -v -r rootfs -m 2KiB -e 124KiB -c 2047 -o tmp_rootfs.img

  	% ubinize -v -o rootfs_ubi.img -m 2KiB -p 128KiB -s 2048 -O 2048 ubinize.cfg
  
  	% rm tmp_rootfs.img


	- The file rootfs_ubi.img contains the ubifs image of the root file system.


  17.5 Burning ubifs image to flash:
  ----------------------------------

	Assume we would like to burn an image with the name /tmp/rootfs_ubi.img to the
 	mtd partition mtd2. For this purpose execute the following commands on the target system:

	% ubiformat /dev/mtd2 -s 2048 -O 2048 -f /tmp/rootfs_ubi.img


  17.6 Booting a ubifs root file system:
  --------------------------------------

	Assume that mtd2 contains the root file system in the ubivolume named rootfs. In this case
 	the following parameters have to be added to the bootargs:

	ubi.mtd=2,2048 root=ubi0:rootfs rootfstype=ubifs


 17.7 Creating/mounting ubi partitions at run time:
 --------------------------------------------------

	Assume that we want to create a ubi file system with a size of 32MB on mtd2.
	To this purpose execute the following commands:

	% ubiformat /dev/mtd2 -s 2048

	% ubiattach /dev/ubi_ctrl -m 2 -O 2048

	% ubimkvol /dev/ubi0 -N some_name -s 32MiB

	% mkdir -p /mnt/some_name

	% mount -t ubifs ubi0:some_name /mnt/some_name

18.  Dual CPU Support for MV78200 SoC (relevant only for DD)
--------------------------------------
    o Dual CPU system supported for DB-78200-A-BP board only, 
      and requires special version of U-Boot
    o To enable 2nd CPU set "enaMP" U-Boot variable to "yes"
    o U-Boot environment the new variables to boot Linux on 2nd CPU:
	 -> ipaddr2
	 -> console2
	 -> bootargs_root2
	 -> bootargs_end2
	 -> image_name2
	 -> bootcmd2 etc. 
	Please refer U-Boot documentation for more details	
    o The LSP for MV78200 provides execution of two independent Linux OS while
	same binary image is used to run either on core 0 or 1
    o The board must have two DIMM installed each Linux OS uses different DIMM  	
    o The SoC units can be mapped to different CPUs according to kernel command line - 
	see "cpu_res" U-Boot environment variable
    o Command line format to assign SoC unit to specific CPU:
	cpu<core_id>=egiga<GbE_num>,egiga<GbE_num>,pcie<pcie_x4_num>,sata,nor,nand,spi,
	usb<usb_if_num>,tdm
	- Example configuration: 
	"cpu0=egiga0,egiga1,sata,nor,nand,spi,usb0,usb2,tdm" 
	GbE0 and 1,integrated SATA, NOR,NAND and SPI flash, 
	USB0 and 2 and TDM are assigned to core 0 
	- Limitations:
		-> No spaces are allowed in configration string
		-> PCI-E interfaces can be assigned to CPU in groups of 4, "pcie1" in
		   command line means that PCI-E 1.0, 1.1, 1.2 and 1.3 now "belong"
		   to CPU 1.
	- All SoC units except of UART1, Giga2 and Giga3 are assigned to CPU0 by default


19. LCD:
========
  U-boot parameters:
  lcd0_enable
	Type int, default value 0
	Description Set to 1 to enable LCD output. U-Boot uses this variable to set the value
	of the clcd.lcd0_enable parameter that is passed to the kernel in the
	command line.

  lcd0_params
	Type string
	Description LCD 0 parameters, formula:
		<xres>x<yres>-<bpp>@<refresh
		rate>[-edid][-<out-xres>x<out-yres>]

	where
	xres = X-axes resolution
	yres = Y-axes resolution
	bpp = bits per pixel
	The -edid part is optional and enables edid detection.

	When it is used, the driver sets the resolution according to the screen
	edid information.
	xout-xres: X-axis resolution of the output screen. When not provided, the	
	driver use xres.
	yout-yres: Y-axis resolution of the output screen. When not provided, the
	driver uses yres.
	U-Boot uses these variables to set the value of the video parameter that
	is passed to the kernel in the command line.

