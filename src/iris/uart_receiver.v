`timescale 1ns / 1ps

/*************************************************************************/

module uart_receiver
(
    input  wire       clk,
    input  wire       reset_b,
    input  wire       rx,
    output reg        ready,
    output wire [7:0] data
);

// Receiver states
localparam RECV_WAIT  = 2'd0; // Waiting for start bit
localparam RECV_START = 2'd1; // Got start bit, waiting for data.
localparam RECV_DATA  = 2'd2; // Getting data
localparam RECV_STOP  = 2'd3; // Waiting for stop bit

/*************************************************************************/

reg [1:0] state;
reg [4:0] tick;
reg [3:0] recv_count;

reg [7:0] recv_data;

always @(posedge clk or negedge reset_b)
begin
    if (!reset_b)
    begin
        tick <= 0;
        state <= RECV_WAIT;
    end
    else
    begin
        case (state)

        RECV_WAIT:
        begin
            if (~rx)
            begin
                state <= RECV_START;
                tick <= 0;
            end
        end

        RECV_START:
        begin
            if (tick == 7)
            begin
                state <= RECV_DATA;
                tick <= 0;

                recv_data <= { rx, 7'd0 };
                recv_count <= 1;
            end
            else
                tick <= tick + 1;
        end

        RECV_DATA:
        begin
            if (tick == 15)
            begin
                tick <= 0;
                recv_data <= { rx, recv_data[7:1] }; // Shift in bit.

                if (recv_count == 3'd7)
                begin
                    ready <= 1;
                    state <= RECV_STOP;
                end

                recv_count <= recv_count + 1;
            end
            else
                tick <= tick + 1;
        end

        RECV_STOP:
        begin
            if (tick == 15)
            begin
                state <= RECV_WAIT;
                ready <= 0;
            end
            else
                tick <= tick + 1;
        end

        endcase
    end
end

assign data = recv_data;

endmodule

/*************************************************************************/

