`timescale 1ns / 1ps

module palette
#(
    parameter ADDR_SZ = 8, // Size of palette in address bits.

    parameter R_BITS = 4,
    parameter G_BITS = 4,
    parameter B_BITS = 4
)
(
    input  wire                 clk,
    input  wire                 reset_b,
    input  wire [ADDR_SZ - 1:0] index,

    input  wire                 we,

    input  wire [R_BITS - 1:0]  red_in,
    input  wire [G_BITS - 1:0]  green_in,
    input  wire [B_BITS - 1:0]  blue_in,

    output reg  [R_BITS - 1:0]  red_out,
    output reg  [G_BITS - 1:0]  green_out,
    output reg  [B_BITS - 1:0]  blue_out
);

localparam ADDR_HI = (1 << ADDR_SZ) - 1;

localparam HI_BIT = (R_BITS + G_BITS + B_BITS) - 1;

localparam R_HI = (R_BITS + G_BITS + B_BITS) - 1;
localparam R_LO = (G_BITS + B_BITS);

localparam G_HI = (G_BITS + B_BITS) - 1;
localparam G_LO = B_BITS;

localparam B_HI = B_BITS - 1;
localparam B_LO = 0;

reg[HI_BIT:0] pal_ram[0:ADDR_HI];

initial
begin
    $readmemh("default_pal.txt", pal_ram);
end

always @(posedge clk)
begin
    if (!reset_b)
    begin
        // Return black while in reset.
        red_out   <= 0;
        green_out <= 0;
        blue_out  <= 0;
    end
    else
    begin
        if (we)
        begin
            pal_ram[index][R_HI:R_LO] <= red_in;
            pal_ram[index][G_HI:G_LO] <= green_in;
            pal_ram[index][B_HI:B_LO] <= blue_in;
        end

        red_out   <= pal_ram[index][R_HI:R_LO];
        green_out <= pal_ram[index][G_HI:G_LO];
        blue_out  <= pal_ram[index][B_HI:B_LO];
    end
end

endmodule
