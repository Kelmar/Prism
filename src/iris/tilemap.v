`timescale 1ns / 1ps

module tilemap
(
    input  wire       clk,
    input  wire       reset_b,

    input  wire [9:0] x_offset,
    input  wire [9:0] y_offset,

    output reg [7:0] index
);

reg [7:0] map_data[0:1023]; // 32x32 map of 1024 tiles
reg [7:0] tile_data[0:65535]; // 256 tiles of 16x16 pixels at 8bpp

initial
begin
    $readmemh("map_data.txt", map_data);
    $readmemh("tiles.txt", tile_data);
end

wire [4:0] tile_x = x_offset[8:4];
wire [4:0] tile_y = y_offset[8:4];

wire [9:0] tile_index = { tile_y[4:0], tile_x[4:0] };

wire [3:0] pixel_x = x_offset[3:0];
wire [3:0] pixel_y = y_offset[3:0];

wire [15:0] tile_offset = { map_data[tile_index], pixel_y[3:0], pixel_x[3:0] };

always @(posedge clk or negedge reset_b)
begin
    if (!reset_b)
    begin
        index <= 0;
    end
    else
    begin
        index <= tile_data[tile_offset];
    end
end

endmodule