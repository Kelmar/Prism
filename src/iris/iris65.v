`timescale 1ms / 1us

// Include not needed with Vivado's project file.
// `include "sync_generator.v"

/*************************************************************************/

module iris65
(
    input  wire in_clk,     // 100 MHz clock
    //input  wire reset_b,    // Reset (low logic)
    input wire reset,       // Reset (high logic)
    input wire btn_up,
    input wire btn_down,
    input wire btn_left,
    input wire btn_right,
    input wire RsRx,
    output wire RsTx,
    output wire hsync_b,    // Horizontal sync pulse (low logic)
    output wire vsync_b,    // Vertical sync pulse (low logic)
    output wire blank_b,    // Picture blanking (low logic)
    output wire[3:0] vga_r, // Red channel output
    output wire[3:0] vga_g, // Green channel output
    output wire[3:0] vga_b  // Blue channel output
);

/*************************************************************************/
// Video dot clock logic

wire reset_b; // Our circuit will have a reset_b, but the Basys 3, uses a positive logic reset.
assign reset_b = ~reset; // Invert

wire dot_clk; // Dot clock wire.

clk_wiz_0 vga_clk
(
    .in_clk(in_clk),
    .dot_clk(dot_clk)
);

//assign dot_clk = in_clk; // Vivado's simulator seems broken with the clock module.

/*************************************************************************/
// UART logic

reg        uart_rd;
wire       uart_rd_ready;
wire [7:0] uart_rd_data;

uart_core uart
(
    .in_clk(in_clk),
    .reset_b(reset_b),
    .rx(RsRx),
    .tx(RsTx),

    .rd_ready(uart_rd_ready),
    .rd_full(),
    .rd(uart_rd),
    .rd_data(uart_rd_data)
);

always @(posedge in_clk or negedge reset_b)
begin
    if (!reset_b)
    begin
        uart_rd <= 0;
    end
end

/*************************************************************************/

wire[9:0] h_screen_pos;
wire[9:0] v_screen_pos;

wire[9:0] h_pixel;
wire[9:0] v_pixel;

sync_generator sync_gen
(
    .clk(dot_clk),
    .reset_b(reset_b),
    .hcnt(h_screen_pos),
    .vcnt(v_screen_pos),
    .blank_b(blank_b),
    .hsync_b(hsync_b),
    .vsync_b(vsync_b)
);

/*
reg [7:0] frame_cnt;

always @(negedge vsync_b or negedge reset_b)
begin
    if (!reset_b)
    begin
        frame_cnt <= 0;
    end
    else
    begin
        frame_cnt <= frame_cnt + 1;
    end
end
*/

assign h_pixel = { 1'd0, h_screen_pos[9:1] };
assign v_pixel = { 1'd0, v_screen_pos[9:1] }; 

/*************************************************************************/

reg [9:0] scroll_x = 0;
reg [9:0] scroll_y = 0;

reg [9:0] x_pos;
reg [9:0] y_pos;

always @(*)
begin
    if (btn_up) scroll_y = 1;
    else if (btn_down) scroll_y = -1;
    else scroll_y = 0;

    if (btn_left) scroll_x = 1;
    else if (btn_right) scroll_x = -1;
    else scroll_x = 0;
end

/*************************************************************************/

wire [9:0] x_offset = h_pixel + x_pos;
wire [9:0] y_offset = v_pixel + y_pos;

always @(negedge vsync_b or negedge reset_b)
begin
    if (!reset_b)
    begin
        x_pos <= 0;
        y_pos <= 0;
    end
    else
    begin
        x_pos <= x_pos + scroll_x;
        y_pos <= y_pos + scroll_y;
    end
end

/*************************************************************************/

wire [7:0] layer1_index;

tilemap layer1
(
    .clk(dot_clk),
    .reset_b(reset_b),

    .x_offset(x_offset),
    .y_offset(y_offset),

    .index(layer1_index)
);

/*************************************************************************/

reg pal_we;

reg[3:0] red_in;
reg[3:0] green_in;
reg[3:0] blue_in;

wire[3:0] red_out;
wire[3:0] green_out;
wire[3:0] blue_out;

always @(negedge reset_b)
begin
    pal_we <= 0;
    red_in <= 0;
    green_in <= 0;
    blue_in <= 0;
end

palette pal(
    .clk(dot_clk),
    .reset_b(reset_b),
    .index(layer1_index),
    .we(pal_we),
    .red_in(red_in),
    .green_in(green_in),
    .blue_in(blue_in),
    .red_out(red_out),
    .green_out(green_out),
    .blue_out(blue_out)
);

/*************************************************************************/
// Final 12-bit VGA output

//wire draw = blank_b && h_pixel[9:4] < 16 && v_pixel[9:4] < 16;

assign vga_r = blank_b ? red_out : 0;
assign vga_g = blank_b ? green_out : 0;
assign vga_b = blank_b ? blue_out : 0;

/*************************************************************************/

endmodule
