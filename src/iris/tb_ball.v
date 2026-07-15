`timescale 10us / 100ns;

module tb_ball();

reg clk;
reg reset_b;

reg vsync_b;

reg[9:0] hpixel;
reg[9:0] vpixel;

wire ball_hgfx;
wire ball_vgfx;
wire ball_gfx;

ball test(
    .ball_clk(vsync_b),
    .reset_b(reset_b),
    .hpixel(hpixel),
    .vpixel(vpixel),
    .r(ball_hgfx),
    .g(ball_gfx),
    .b(ball_vgfx)
);

initial
begin
    clk = 0;
    reset_b = 0;
    hpixel = 0;
    vpixel = 0;
    vsync_b = 0;
end

always
begin
    #10 clk = ~clk;
    
    if (clk && reset_b)
    begin
        vsync_b = 0;
        hpixel = hpixel + 1;
        
        if (hpixel >= 320)
        begin
            hpixel = 0;
            
            vpixel = vpixel + 1;
            
            if (vpixel >= 240)
            begin
                vpixel = 0;
                vsync_b = 0;
            end
        end    
    end
    
    if (!clk && !reset_b)
        reset_b = 1;
end

endmodule
