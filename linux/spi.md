GPIO in linux
-------------

# Change DTS for development / debugging

    spidev@0{
            compatible = "spidev";
            reg = <0>;
            spi-max-frequency = <100000>;
    };

# Use SPI tools

Sources: https://github.com/cpb-/spi-tools/

    sudo apt install spi-tools
    sudo spi-config -d /dev/spidev0.0 -q

    sudo spi-pipe -d /dev/spidev0.0 < /dev/zero | hexdump -C
    printf '\x01\x82\xF3' | sudo spi-pipe -d /dev/spidev0.0 | hexdump -C

> For `hexdump`: `sudo apt install bsdmainutils`
