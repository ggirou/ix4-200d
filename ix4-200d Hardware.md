Iomega StorCenter ix4-200d
--------------------------

From: https://deviwiki.com/wiki/Iomega_StorCenter_ix4-200d

- CPU1: Marvell 88F6281 (1.2 GHz)
- FLA1: 32 MiB (Hynix HY27US08561A-TPCB)
- RAM1: 512 MiB (Nanya NT5TU128M8GE-AC × 4)

- Expansion IFs: USB 2.0, SATA
- USB ports: 3
- SATA ports: 4

- ETH chip1: Marvell 88F6281
- ETH chip2: Marvell 88E1116R
- ETH chip3: Marvell 88E1116R
- LAN speed: 1G
- LAN ports: 2

# Additional chips

```csv
PCIe to SATA RAID Controller;Marvell;88SE6121;;1;
USB 2.0 Low Power Hub Controller;Genesys Logic;GL850A;;1;
Remote Thermal Monitor and Fan Control;ON Semiconductor;ADT7473;;1;
Remote 8-Bit I2C and SMBus Low-Power I/O Expander;Texas Instruments;PCA9534;;1;
Dual PWM Step Down Controller w/ Low Power LDO, RTC Regulator;Maxim;MAX17020;;1;
Dual Operational Amplifier;Texas Instruments;LM358;;2;
30V P-Channel MOSFET;Vishay Siliconix;Si4435BDY;;1;
30V P-Channel MOSFET;Alpha&Omega Semiconductor;AO4407A;;1;
30V N-Channel MOSFET;Alpha&Omega Semiconductor;AO4712;;2;
30V N-Channel MOSFET;Alpha&Omega Semiconductor;AO4468;;2;
30V Dual N-Channel MOSFET;Alpha&Omega Semiconductor;AO4818B;;1;
P-Channel Enhancement Mode Field Effect Transistor;Alpha&Omega Semiconductor;AO4433;;1;
3A Low Dropout Positive Adjustable Regulator;ANPEC;APL1085;;1;
3A Ultra Low Dropout Linear Regulator;ANPEC;APL5930;;1;
3A, 12V Synchronous Rectified Buck Converter;ANPEC;APW7145;;1;
8-bit serial-in, parallel-out shift register;NXP;74HC164D;;1;
Hex Buffer and Driver With Open-Drain Outputs;Texas Instruments;SN74LVC07A;;1;
Dual Positive-Edge-Triggered D-Type Flip-Flop;Texas Instruments;SN74AHC74;;1;
```

# Hardware Spec / Datasheet

- Marvell 88F6281: https://lafibre.info/images/free/201101_Marvell_Kirkwood_88F6281_2_Hardware_Spec.pdf
- PCA9534: https://www.nxp.com/docs/en/data-sheet/PCA9534.pdf
- 74HC164D: https://assets.nexperia.com/documents/data-sheet/74HC_HCT164.pdf
- APW7145 : https://datasheetspdf.com/pdf-file/659354/AnpecElectronicsCoropration/APW7145/1

# DTS

- Generics:

  - https://www.kernel.org/doc/Documentation/devicetree/bindings/gpio/gpio.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/i2c/i2c-gpio.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/spi/spi-gpio.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/power/reset/gpio-poweroff.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/ata/sata-common.yaml
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/regulator/fixed-regulator.txt

- Marvell 88F6281:

  - https://www.kernel.org/doc/Documentation/devicetree/bindings/pinctrl/marvell%2Ckirkwood-pinctrl.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/pinctrl/marvell%2Cmvebu-pinctrl.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/gpio/gpio-mvebu.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/bus/mvebu-mbus.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/i2c/i2c-mv64xxx.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/pci/mvebu-pci.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/ata/marvell.txt

- ADT7473:

  - https://www.kernel.org/doc/Documentation/devicetree/bindings/hwmon/adt7475.yaml

- PCA9534:

  - https://www.kernel.org/doc/Documentation/devicetree/bindings/gpio/gpio-pca953x.txt
  - https://www.kernel.org/doc/Documentation/devicetree/bindings/i2c/i2c-mux-pca954x.txt

- 74HC164D:

  - https://www.kernel.org/doc/Documentation/devicetree/bindings/gpio/gpio-74x164.txt

----------------------------

# Marvell Kirkwood SoC pinctrl driver for mpp

Source : https://www.kernel.org/doc/Documentation/devicetree/bindings/pinctrl/marvell%2Ckirkwood-pinctrl.txt

Please refer to marvell,mvebu-pinctrl.txt in this directory for common binding
part and usage.

Required properties:
- compatible: "marvell,88f6180-pinctrl",
              "marvell,88f6190-pinctrl", "marvell,88f6192-pinctrl",
              "marvell,88f6281-pinctrl", "marvell,88f6282-pinctrl",
              "marvell,98dx4122-pinctrl", "marvell,98dx1135-pinctrl"
- reg: register specifier of MPP registers

This driver supports all kirkwood variants, i.e. 88f6180, 88f619x, and 88f628x.
It also support the 88f6281-based variant in the 98dx412x Bobcat SoCs.

Available mpp pins/groups and functions:
Note: brackets (x) are not part of the mpp name for marvell,function and given
only for more detailed description in this document.

## Marvell Kirkwood 88f6281

    name          pins     functions
    ================================================================================
    mpp0          0        gpio, nand(io2), spi(cs)
    mpp1          1        gpo, nand(io3), spi(mosi)
    mpp2          2        gpo, nand(io4), spi(sck)
    mpp3          3        gpo, nand(io5), spi(miso)
    mpp4          4        gpio, nand(io6), uart0(rxd), ptp(clk), sata1(act)
    mpp5          5        gpo, nand(io7), uart0(txd), ptp(trig), sata0(act)
    mpp6          6        sysrst(out), spi(mosi), ptp(trig)
    mpp7          7        gpo, pex(rsto), spi(cs), ptp(trig)
    mpp8          8        gpio, twsi0(sda), uart0(rts), uart1(rts), ptp(clk),
                          mii(col), mii-1(rxerr), sata1(prsnt)
    mpp9          9        gpio, twsi(sck), uart0(cts), uart1(cts), ptp(evreq),
                          mii(crs), sata0(prsnt)
    mpp10         10       gpo, spi(sck), uart0(txd), ptp(trig), sata1(act)
    mpp11         11       gpio, spi(miso), uart0(rxd), ptp(clk), ptp-1(evreq),
                          ptp-2(trig), sata0(act)
    mpp12         12       gpio, sdio(clk)
    mpp13         13       gpio, sdio(cmd), uart1(txd)
    mpp14         14       gpio, sdio(d0), uart1(rxd), mii(col), sata1(prsnt)
    mpp15         15       gpio, sdio(d1), uart0(rts), uart1(txd), sata0(act)
    mpp16         16       gpio, sdio(d2), uart0(cts), uart1(rxd), mii(crs),
                          sata1(act)
    mpp17         17       gpio, sdio(d3), sata0(prsnt)
    mpp18         18       gpo, nand(io0)
    mpp19         19       gpo, nand(io1)
    mpp20         20       gpio, ge1(txd0), ts(mp0), tdm(tx0ql), audio(spdifi),
                          sata1(act)
    mpp21         21       gpio, ge1(txd1), sata0(act), ts(mp1), tdm(rx0ql),
                          audio(spdifo)
    mpp22         22       gpio, ge1(txd2), ts(mp2), tdm(tx2ql), audio(rmclk),
                          sata1(prsnt)
    mpp23         23       gpio, ge1(txd3), sata0(prsnt), ts(mp3), tdm(rx2ql),
                          audio(bclk)
    mpp24         24       gpio, ge1(rxd0), ts(mp4), tdm(spi-cs0), audio(sdo)
    mpp25         25       gpio, ge1(rxd1), ts(mp5), tdm(spi-sck), audio(lrclk)
    mpp26         26       gpio, ge1(rxd2), ts(mp6), tdm(spi-miso), audio(mclk)
    mpp27         27       gpio, ge1(rxd3), ts(mp7), tdm(spi-mosi), audio(sdi)
    mpp28         28       gpio, ge1(col), ts(mp8), tdm(int), audio(extclk)
    mpp29         29       gpio, ge1(txclk), ts(mp9), tdm(rst)
    mpp30         30       gpio, ge1(rxclk), ts(mp10), tdm(pclk)
    mpp31         31       gpio, ge1(rxclk), ts(mp11), tdm(fs)
    mpp32         32       gpio, ge1(txclko), ts(mp12), tdm(drx)
    mpp33         33       gpo, ge1(txclk), tdm(drx)
    mpp34         34       gpio, ge1(txen), tdm(spi-cs1), sata1(act)
    mpp35         35       gpio, ge1(rxerr), sata0(act), mii(rxerr), tdm(tx0ql)
    mpp36         36       gpio, ts(mp0), tdm(spi-cs1), audio(spdifi)
    mpp37         37       gpio, ts(mp1), tdm(tx2ql), audio(spdifo)
    mpp38         38       gpio, ts(mp2), tdm(rx2ql), audio(rmclk)
    mpp39         39       gpio, ts(mp3), tdm(spi-cs0), audio(bclk)
    mpp40         40       gpio, ts(mp4), tdm(spi-sck), audio(sdo)
    mpp41         41       gpio, ts(mp5), tdm(spi-miso), audio(lrclk)
    mpp42         42       gpio, ts(mp6), tdm(spi-mosi), audio(mclk)
    mpp43         43       gpio, ts(mp7), tdm(int), audio(sdi)
    mpp44         44       gpio, ts(mp8), tdm(rst), audio(extclk)
    mpp45         45       gpio, ts(mp9), tdm(pclk)
    mpp46         46       gpio, ts(mp10), tdm(fs)
    mpp47         47       gpio, ts(mp11), tdm(drx)
    mpp48         48       gpio, ts(mp12), tdm(dtx)
    mpp49         49       gpio, ts(mp9), tdm(rx0ql), ptp(clk)
