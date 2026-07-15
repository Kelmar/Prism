module ball
#(
    parameter START_X = 159,
    parameter START_Y = 119,
    parameter START_DELTA_X = -1,
    parameter START_DELTA_Y = -1
)
(
    input  wire reset_b,
    input  wire ball_clk,
    input  wire[9:0] hpixel,
    input  wire[9:0] vpixel,
    output wire r,
    output wire g,
    output wire b
);

//localparam BALL_MAX_X = 640;
//localparam BALL_MAX_Y = 480;

localparam BALL_MAX_X = 320;
localparam BALL_MAX_Y = 240;

reg[9:0] ball_pos_x;
reg[9:0] ball_pos_y;

reg[9:0] ball_delta_x;
reg[9:0] ball_delta_y;

wire ball_gfx_x = ball_pos_x == hpixel;
wire ball_gfx_y = ball_pos_y == vpixel;

wire ball_gfx = ball_gfx_x && ball_gfx_y;

wire ball_collide_x = (ball_pos_x == 0) || (ball_pos_x >= BALL_MAX_X);
wire ball_collide_y = (ball_pos_y == 0) || (ball_pos_y >= BALL_MAX_Y);

always @(posedge ball_clk or negedge reset_b)
begin
    if (!reset_b)
    begin
        ball_pos_x <= START_X;
        ball_pos_y <= START_Y;

        ball_delta_x <= START_DELTA_X;
        ball_delta_y <= START_DELTA_Y;
    end
    else
    begin
        if (ball_collide_x)
        begin
            ball_delta_x <= -ball_delta_x;
            ball_pos_x   <= ball_pos_x - ball_delta_x;
        end
        else
        begin
            ball_pos_x <= ball_pos_x + ball_delta_x;
        end

        if (ball_collide_y)
        begin
            ball_delta_y <= -ball_delta_y;
            ball_pos_y   <= ball_pos_y - ball_delta_y;
        end
        else
        begin
            ball_pos_y <= ball_pos_y + ball_delta_y;
        end
    end
end

assign r = ball_gfx_y;
assign g = ball_gfx;
assign b = ball_gfx_x;

endmodule
