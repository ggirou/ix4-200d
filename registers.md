# Functional specification

Source: http://natisbad.org/NAS/refs/Marvell/FS_88F6180_9x_6281_OpenSource.pdf

Register Name       Offset
GPIO Data Out Register 0x10100
GPIO Data Out Enable Control Register 0x10104
GPIO Blink Enable Register 0x10108
GPIO Data In Polarity Register 0x1010C
GPIO Data In Register 0x10110
GPIO Interrupt Cause Register 0x10114
GPIO Interrupt Mask Register 0x10118
GPIO Interrupt Level Mask Register 0x1011C
GPIO High Data Out Register 0x10140
GPIO High Data Out Enable Control Register 0x10144
GPIO High Blink Enable Register 0x10148
GPIO High Data In Polarity Register 0x1014C
GPIO High Data In Register 0x10150
GPIO High Interrupt Cause Register 0x10154
GPIO High Interrupt Mask Register 0x10158
GPIO High Interrupt Level Mask Register 0x1015C


# u-boot constants

    #define KW88F6281_REGS_PHYS_BASE	0xf1000000
    #define KW_REGS_PHY_BASE		KW88F6281_REGS_PHYS_BASE

    #define INTREG_BASE			0xd0000000
    #define KW_REGISTER(x)			(KW_REGS_PHY_BASE + x)
    #define KW_OFFSET_REG			(INTREG_BASE + 0x20080)

    /* undocumented registers */
    #define KW_REG_UNDOC_0x1470		(KW_REGISTER(0x1470))
    #define KW_REG_UNDOC_0x1478		(KW_REGISTER(0x1478))

    #define MVEBU_SDRAM_BASE		(KW_REGISTER(0x1500))
    #define KW_TWSI_BASE			(KW_REGISTER(0x11000))
    #define KW_UART0_BASE			(KW_REGISTER(0x12000))
    #define KW_UART1_BASE			(KW_REGISTER(0x12100))
    #define KW_MPP_BASE			(KW_REGISTER(0x10000))
    #define MVEBU_GPIO0_BASE			(KW_REGISTER(0x10100))
    #define MVEBU_GPIO1_BASE			(KW_REGISTER(0x10140))
    #define KW_RTC_BASE			(KW_REGISTER(0x10300))
    #define KW_NANDF_BASE			(KW_REGISTER(0x10418))
    #define MVEBU_SPI_BASE			(KW_REGISTER(0x10600))
    #define MVEBU_CPU_WIN_BASE			(KW_REGISTER(0x20000))
    #define KW_CPU_REG_BASE			(KW_REGISTER(0x20100))
    #define MVEBU_TIMER_BASE			(KW_REGISTER(0x20300))
    #define KW_REG_PCIE_BASE		(KW_REGISTER(0x40000))
    #define KW_USB20_BASE			(KW_REGISTER(0x50000))
    #define KW_EGIGA0_BASE			(KW_REGISTER(0x72000))
    #define KW_EGIGA1_BASE			(KW_REGISTER(0x76000))
    #define KW_SATA_BASE			(KW_REGISTER(0x80000))
    #define KW_SDIO_BASE			(KW_REGISTER(0x90000))

# u-boot commands

    echo KW_MPP_BASE	; md 0xf1010000
    echo MVEBU_GPIO0_BASE	; md 0xf1010100
    echo MVEBU_GPIO1_BASE	; md 0xf1010140

    echo KW_REG_UNDOC_0x1470; md 0xf1001470
    echo KW_REG_UNDOC_0x1478; md 0xf1001478

    echo MVEBU_SDRAM_BASE; md 0xf1001500
    echo KW_TWSI_BASE	; md 0xf1011000
    echo KW_UART0_BASE	; md 0xf1012000
    echo KW_UART1_BASE	; md 0xf1012100
    echo KW_RTC_BASE	; md 0xf1010300
    echo KW_NANDF_BASE	; md 0xf1010418
    echo MVEBU_SPI_BASE	; md 0xf1010600
    echo MVEBU_CPU_WIN_BASE	; md 0xf1020000
    echo KW_CPU_REG_BASE	; md 0xf1020100
    echo MVEBU_TIMER_BASE	; md 0xf1020300
    echo KW_REG_PCIE_BASE; md 0xf1040000
    echo KW_USB20_BASE	; md 0xf1050000
    echo KW_EGIGA0_BASE	; md 0xf1072000
    echo KW_EGIGA1_BASE	; md 0xf1076000
    echo KW_SATA_BASE	; md 0xf1080000
    echo KW_SDIO_BASE	; md 0xf1090000

    echo KW_OFFSET_REG; md 0xd0020080
