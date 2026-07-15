`timescale 1ns / 1ps

/*************************************************************************/

module ram_async_tristate
#(
    parameter A = 10,
    parameter D = 8
)
(
    input clk,
    input [A - 1:0] addr,
    input oe,
    input we,

    input  [D - 1:0] din,
    output [D - 1:0] dout
);

reg[D - 1:0] mem [0:(1 << A) - 1];

always @(posedge clk)
begin
    if (we)
    begin
        mem[addr] <= din;
    end
end

assign dout = !oe ? mem[addr] : {D{1'bz}};

endmodule

/*************************************************************************/

module ram_async
#(
    parameter A = 10,
    parameter D = 8
)
(
    input clk,
    input [A - 1:0] addr,
    input we,

    input  [D - 1:0] din,
    output [D - 1:0] dout
);

reg[D - 1:0] mem [0:(1 << A) - 1];

always @(posedge clk)
begin
    if (we)
    begin
        mem[addr] <= din;
    end
end

assign dout = mem[addr];

endmodule

/*************************************************************************/

module ram_sync
#(
    parameter A = 10,
    parameter D = 8
)
(
    input  clk,
    input  [A - 1:0] addr,
    input  we,
    
    input  [D - 1:0] din,
    output [D - 1:0] dout
);

reg[D - 1:0] mem [0:(1 << A) - 1];

always @(posedge clk)
begin
    if (we)
    begin
        mem[addr] <= din;
    end
    
    dout <= mem[addr];
end

endmodule

/*************************************************************************/
