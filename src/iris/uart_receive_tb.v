`timescale 1ns / 1ps

/*************************************************************************/

module uart_receive_tb();

reg clk;
reg reset_b;
reg rx;

wire ready;
wire [7:0] data;

uart_receiver test
(
    .clk(clk),
    .reset_b(reset_b),

    .rx(rx),
    .ready(ready),

    .data(data)
);

initial
begin
    clk = 0;
    reset_b = 0;
    rx = 1;
    //data = 0'h00;
end

integer i;

task run_clock(input [7:0] x);
    integer j;

    for (j = 0; j < x; j = j + 1)
    begin
        #10 clk = ~clk;
        #10 clk = ~clk;
    end
endtask

task send_byte(input [7:0] value);
    integer i;
    integer x;
begin
    x = value;

    #10 clk = ~clk; // Hi
    rx = 0; // Start bit

    #10 clk = ~clk; // Lo
    run_clock(7);

    for (i = 0; i < 8; i = i + 1)
    begin
        if (ready)
            $error("Expected receiver to not be ready yet.");

        rx = value[0];
        value = { 1'b0, value[7:1] };

        run_clock(16);
    end

    if (!ready)
        $error("Expected receiver to be ready after first loop.");

    if (data != x)
        $error("Expected data to be %b, but was %b after first loop.", x, data);

    #10 clk = ~clk; // Hi
    rx = 1; // Stop bit

    #10 clk = ~clk; // Lo

    run_clock(15);
end
endtask

always
begin
    #10 clk = ~clk; // Hi
    #10 clk = ~clk; // Lo
    reset_b = 1;
   
    send_byte(8'd255);
    send_byte(8'h55);
    send_byte(8'hAA);
    send_byte(8'h00);
end

endmodule

/*************************************************************************/
