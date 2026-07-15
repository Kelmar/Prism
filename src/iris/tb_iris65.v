`timescale 10us / 100ns

module tb_iris65();

reg clk;

reg reset;

wire hsync_b;    // Horizontal sync pulse (low logic)
wire vsync_b;    // Vertical sync pulse (low logic)
wire blank_b;    // Picture blanking (low logic)
wire[3:0] vga_r; // Red channel output
wire[3:0] vga_g; // Green channel output
wire[3:0] vga_b; // Blue channel output

iris65 test(
    .in_clk(clk),
    .reset(reset),
    .hsync_b(hsync_b),
    .vsync_b(vsync_b),
    .blank_b(blank_b),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b)
);

initial
begin
    clk = 0;
    reset = 1;
end

always
begin
    #1 clk = ~clk;
    
    if (!clk && reset)
    begin
        reset = 0;
    end;
end

endmodule
