`timescale 1ns / 1ps

/*************************************************************************/

module uart
#(
    parameter IN_CLK_FQ = 100000000, // Clock frequency in HZ
    parameter BAUD_RATE = 9600
)
(
    input  wire       in_clk,   // Input clock
    input  wire       reset_b,  // Reset (low level logic)

    input  wire       rx,       // Receive data bits
    //output wire       tx,       // Transmit data bits

    output wire       rd_ready, // Set when a byte is ready to be processed.
    output wire       rd_full,  // Set when receive fifo is full.
    input  wire       rd,       // Request to read byte from fifo
    output wire [7:0] rd_data  // Fifo byte read

    //output wire       tx_full,  // Transmitter FIFO is full.
    //input  wire       wr,       // Request to fifo.
    //input  wire [7:0] wr_data   // Data to write to fifo.
);

/*************************************************************************/

localparam BAUD_X16 = BAUD_RATE * 16;
localparam COUNTER_MAX = (IN_CLK_FQ / BAUD_X16);

//localparam COUNTER_BITS = $clog2(COUNTER_MAX) - 1;

/*************************************************************************/

reg [31:0] baud_counter;

// Should result in 16x baud clock for over sampling of rx input.
wire baud_clk;

assign baud_clk = baud_counter == (COUNTER_MAX - 1);

always @(posedge in_clk or negedge reset_b)
begin
    if (!reset_b || baud_clk)
        baud_counter <= 0;
    else
        baud_counter <= baud_counter + 1;
end

/*************************************************************************/

wire recv_rdy;
wire [7:0] recv_byte;
wire recv_empty;

uart_receiver receiver
(
    .clk(baud_clk),
    .reset_b(reset_b),
    .rx(rx),
    .ready(recv_rdy),
    .data(recv_byte)
);

fifo recv_fifo
(
    .in_clk(in_clk),
    .reset_b(reset_b),

    .empty(recv_empty),
    .full(rd_full),

    .wr(recv_rdy),
    .in_data(recv_byte),

    .rd(rd),
    .out_data(rd_data)
);

assign rd_ready = !recv_empty;

/*************************************************************************/
/*
wire tx_empty;

wire [7:0] tx_byte;

uart_transmit transmitter
(
    .clk(baud_clk),
    .reset_b(reset_b),

    .tx(tx),

    .ready(tx_ready),
    .data(tx_byte)
);

fifo trans_fifo
(
    .clk(in_clk),
    .reset_b(reset_b),

    .empty(tx_empty),
    .full(tx_full),

    .wr(wr),
    .data_in(wr_data)

    .rd(),
    .data_out(tx_byte)
);
*/
/*************************************************************************/

endmodule
