`timescale 1ns / 1ps

/*************************************************************************/

module fifo_tb();

reg clk;
reg reset_b;

wire empty;
wire full;

reg wr;
reg rd;

reg [7:0] in_data;
wire [7:0] out_data;

fifo test
(
    .in_clk(clk),
    .reset_b(reset_b),

    .empty(empty),
    .full(full),

    .wr(wr),
    .in_data(in_data),

    .rd(rd),
    .out_data(out_data)
);

initial
begin
    clk = 0;
    reset_b = 0;
    wr = 0;
    in_data = 8'd0;
    //out_data = 8'd0;
    rd = 0;
end

integer i;
integer val;

always
begin
    #10 clk = ~clk; // Hi
    
    #10 clk = ~clk; // Lo
    reset_b = 1;

    for (i = 0; i < 32; i = i + 1)
    begin
        val = i + 8'h55;

        #10 clk = ~clk; // Hi
        in_data = val;
        wr = 1;

        #10 clk = ~clk; // Lo
        wr = 0;

        #10 clk = ~clk; // Hi
        rd = 1;

        if (empty)
            $error("FAIL: Expected buffer to indicate not empty, but shows empty at index %b", i);

        if (full)
            $error("FAIL: Expected buffer to indicate not full, but shows full at index %b", i);

        if (out_data != val)
            $error("FAIL: Expected %b, got %b at index %b", val, out_data, i);

        #10 clk = ~clk; // Lo
        rd = 0;
    end

    #10 clk = ~clk; // Hi
    rd = 1;

    if (!empty)
        $error("FAIL: Expected buffer to indicate empty, but shows not empty at end of first loop.");

    if (full)
        $error("FAIL: Expected buffer to indicate not full, but shows full at end of first loop.", i);

    #10 clk = ~clk; // Lo
    rd = 0;

    for (i = 0; i < 16; i = i + 1)
    begin
        if (full)
            $error("FAIL: Expected buffer to indicate not full, but shows full at index %b", i);

        val = i + 8'hAA;

        #10 clk = ~clk; // Hi
        in_data = val;
        wr = 1;

        #10 clk = ~clk; // Lo
        wr = 0;
    end

    if (empty)
        $error("FAIL: Expected buffer to not be empty after second loop.");

    if (!full)
        $error("FAIL: Expected buffer to be full after second loop.");

    for (i = 0; i < 16; i = i + 1)
    begin
        if (empty)
            $error("FAIL: Expected buffer to be not empty, but shows empty at index %b", i);

        val = i + 8'hAA;

        #10 clk = ~clk; // Hi
        rd = 1;

        if (val != out_data)
            $error("FAIL: Expected value %b, but got %b at index %b", val, out_data, i);

        #10 clk = ~clk; // Lo
        rd = 0;
    end
end

endmodule

/*************************************************************************/

