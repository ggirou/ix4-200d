Device Tree Specification
-------------------------

https://www.devicetree.org/

# Get DTS files

DTS files come fron Linux Kernel :
https://github.com/torvalds/linux/blob/master/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts

Iomega ix2-200

    wget https://raw.githubusercontent.com/torvalds/linux/master/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
    wget https://raw.githubusercontent.com/torvalds/linux/master/arch/arm/boot/dts/kirkwood.dtsi
    wget https://raw.githubusercontent.com/torvalds/linux/master/arch/arm/boot/dts/kirkwood-6281.dtsi

Lenovo ix4-300d

    wget https://raw.githubusercontent.com/torvalds/linux/master/arch/arm/boot/dts/armada-xp-lenovo-ix4-300d.dts

D-Link DNS 320

    wget https://raw.githubusercontent.com/torvalds/linux/master/arch/arm/boot/dts/kirkwood-dns320.dts

# Community DTS

- `kirkwood-iomega_ix4_200d-damacc.dts` by damacc: https://forum.doozan.com/read.php?2,22623,22673#msg-22673
- `kirkwood-iomega_ix4_200d-1000001101000.dts` by 1000001101000: https://github.com/1000001101000/ix4-200d-research/blob/master/device-tree/kirkwood-iomega_ix4_200d.dts
- `kirkwood-iomega_ix4_200d-bodhi.dts` by bodhi: https://github.com/pepaslabs/bodhi-kirkwood-kernel-mirror/blob/master/linux-5.4.2-kirkwood-tld-1.patch#L1215-L1321
- https://forum.doozan.com/read.php?2,94079,94319#msg-94319

# Compile DTS to DTB (doesn't work)

    sudo apt install linux-headers-marvell cpp
    # dtc -O dtb -o kirkwood-ix4-200d.dtb kirkwood-iomega_ix4_200d.dts
    # sed 's|#include|/include/|' kirkwood-iomega_ix4_200d.dts | sudo tee kirkwood-iomega_ix4_200d.dtsi
    # dtc -O dtb -o kirkwood-ix4-200d.dtb kirkwood-iomega_ix4_200d.dtsi
    
    cpp -nostdinc -I include -I arch  -undef -x assembler-with-cpp kirkwood-iomega_ix4_200d.dts kirkwood-iomega_ix4_200d.dts.preprocessed
    dtc -I dts -O dtb -p 0x1000  kirkwood-iomega_ix4_200d.dts.preprocessed -o kirkwood-ix4-200d.dtb

