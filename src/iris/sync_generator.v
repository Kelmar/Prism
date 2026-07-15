`ifndef sync_generator_h
`define sync_generator_h

module sync_generator
(
    input  wire      clk,       // VGA Clock 25.175 MHz
    input  wire      reset_b,   // Reset line (low level logic)
    output reg[9:0]  hcnt,      // Horizontal pixel counter (HC / 2)
    output reg[9:0]  vcnt,      // Vertical pixel counter (VC / 2)
    output wire      blank_b,   // Picture blanking (low level logic)
    output reg       hsync_b,   // Horizontal sync pulse (low level logic)
    output reg       vsync_b    // Vertical sync pulse (low level logic)
);

// Resolution is for 640x480 @ 60Hz

/*
 * 0       48                     688     704
 * | back  | VISIBLE_AREA_PORTION | front | sync  |
 * | porch |                      | porch | pulse |
 */

// Operational constants
parameter HORZ_TOTAL     = 10'd800;
parameter HORZ_RES       = 10'd640;

//parameter HORZ_FRONT     = 10'd16;
parameter HORZ_SYNC      = 10'd96;
parameter HORZ_BACK      = 10'd48;

parameter HORZ_SYNC_START = HORZ_TOTAL - (HORZ_SYNC + HORZ_BACK);
parameter HORZ_SYNC_END   = HORZ_TOTAL - HORZ_BACK - 1;

parameter VERT_TOTAL     = 10'd525;
parameter VERT_RES       = 10'd480;

//parameter VERT_FRONT     = 10'd10;
parameter VERT_SYNC      = 10'd2;
parameter VERT_BACK      = 10'd33;

parameter VERT_SYNC_START = VERT_TOTAL - (VERT_SYNC + VERT_BACK);
parameter VERT_SYNC_END   = VERT_TOTAL - VERT_BACK - 1;

always @(posedge clk or negedge reset_b)
begin
    if (!reset_b)
    begin
        hcnt <= 0;
        vcnt <= 0;
       
        // No sync pulses or picture on reset. 
        hsync_b <= 1;
        vsync_b <= 1;
    end
    else
    begin
        hsync_b <= !(hcnt >= HORZ_SYNC_START && hcnt < HORZ_SYNC_END);
        vsync_b <= !(vcnt >= VERT_SYNC_START && vcnt < VERT_SYNC_END);
        
        if (hcnt == HORZ_TOTAL)
        begin
            hcnt <= 0;
            
            if (vcnt == VERT_TOTAL)
                vcnt <= 0;
            else
                vcnt <= vcnt + 1;
        end
        else
            hcnt <= hcnt + 1;
    end
end

assign blank_b = reset_b && (hcnt < HORZ_RES) && (vcnt < VERT_RES);

endmodule

`endif
