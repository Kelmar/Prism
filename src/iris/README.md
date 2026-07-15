Source code for the Iris graphics module.

Right now this is just a loose collection of some Verilog files.

The goal is to support 320x240 @ 16million colors. (Half of 640x480 with 8bits per color channel)


Because the Basys3 board only as 4bits per color channel we're currently testing with 4096 colors.


Currently in progress:
- Fixing the UART code.
  This code is just here for me to use to debug and test with the Basys3 board I'm using.
- Testing the tile map for a single layer.

Needed:
- Interfacing with a system bus
  Plan is to test this using the PMOD ports on the Basys3 as GPIO pins.

- Sprites

- DMA?
  Might want to handle this with an external module.
