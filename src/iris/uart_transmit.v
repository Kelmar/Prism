`timescale 1ns / 1ps

/*************************************************************************/

module uart_transmit
(
    input  wire clk,
    input  wire reset_b,

    output reg  tx,

    input  wire ready,
    input  wire [7:0] data
);

// Transmitter states
localparam TRANS_WAIT  = 2'd0; // Waiting for a byte to transmit
localparam TRANS_DATA  = 2'd1; // Sending data
localparam TRANS_STOP  = 2'd2; // Sending stop bit
localparam TRANS_DONE  = 2'd3; // Done sending stop bit

/*************************************************************************/

reg[1:0] state;
reg[1:0] next_state;

reg[3:0] tick;
reg[3:0] next_tick;

reg[2:0] bit_counter;
reg[7:0] trans_data;

always @(posedge clk or negedge reset_b)
begin
    if (!reset_b)
    begin
        state <= TRANS_WAIT;
        tick <= 0;
    end
    else
    begin
        state <= next_state;
        tick <= next_tick;
    end
end

always @(posedge clk)
begin
    next_state <= state;

    case (state)

    RECV_WAIT:
    begin
        if (ready)
        begin
            bit_counter <= 0;
            trans_data <= data;
            next_state <= TRANS_DATA;
            next_tick <= 0;
            tx <= 1;
        end
    end

    TRANS_DATA:
    begin
        if (tick == 15)
        begin
            if (bit_counter == 7)
                next_state <= TRANS_STOP;

            bit_counter <= bit_counter + 1;
            tx <= trans_data[7];
            trans_data <= { trans_data[6:0], 1'b0 };
        end
        
        next_tick <= tick + 1;
    end

    TRANS_STOP:
    begin
        if (tick == 15)
            next_state <= TRANS_DONE;

        tx <= 0;
        next_tick <= tick + 1;
    end

    TRANS_DONE:
    begin
        tx <= 1;
        next_state <= TRANS_WAIT;
    end

    endcase
end

/*************************************************************************/

endmodule

/*************************************************************************/