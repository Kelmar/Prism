`timescale 1ns / 1ps

/*************************************************************************/

module fifo
#(
    parameter SIZE = 16 // Size of fifo in bytes
)
(
    input  wire in_clk,
    input  wire reset_b,

    output wire empty,
    output wire full,

    input  wire wr,
    input  wire [7:0] in_data,

    input  wire rd,
    output wire [7:0] out_data
);

localparam SIZE_BITS = $clog2(SIZE);

reg [7:0] buffer[0:(SIZE - 1)];

reg [SIZE_BITS:0] rd_ptr;
reg [SIZE_BITS:0] wr_ptr;

reg [7:0] out;

assign empty = wr_ptr == rd_ptr;
assign full  = (wr_ptr[SIZE_BITS - 1:0] == rd_ptr[SIZE_BITS - 1:0]) &&
               (wr_ptr[SIZE_BITS] != rd_ptr[SIZE_BITS]);

always @(posedge in_clk)
begin
    if (!reset_b)
    begin
        wr_ptr <= 0;
    end
    else
    begin
        if (wr && !full)
        begin
            buffer[wr_ptr[SIZE_BITS - 1:0]] <= in_data;
            wr_ptr <= wr_ptr + 1;
        end
    end
end

always @(posedge in_clk)
begin
    if (!reset_b)
    begin
        rd_ptr <= 0;
        out <= 0;
    end
    else
    begin
        if (rd && !empty)
        begin
            out <= buffer[rd_ptr[SIZE_BITS - 1:0]];
            rd_ptr <= rd_ptr + 1;
        end
    end
end

assign out_data = (in_clk & rd) ? out : 8'hZ;

endmodule

/*************************************************************************/
