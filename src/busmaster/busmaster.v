module busmaster
(
    input  wire      phi0,     // Master clock, we'll devide by half.
    input  wire      vda,      // VDA pin of 65C816 (tie high for 65C02)
    input  wire[2:0] up_addr,  // bits 15, 14, 13 of address space
    input  wire[1:0] mid_addr, // bits 9, 8 of address space
    input  wire[2:0] low_addr, // bits 7, 6, 5 of address space (dev selection)
    input  wire      rwb,      // Read/Write from 65C816/65C02
    input  wire      ior,      // IO ready (edge triggered)
    output wire      rd,       // Read (bar)
    output wire      wr,       // Write (bar)
    output reg       phi2,     // Phase 2 clock (real)
    output reg       phi2_s,   // Phase 2 clock (stretched)
    output reg       ram0,     // 32KB lower ram (bar)
    output reg       ram1,     // 32KB upper ram (bar)
    output reg       rom,      // 8KB rom (bar)
    output reg[7:0]  dev       // Device selection (bar)
);
    // Keeps track of our ior edge
    reg iordy;
    
    // Keeps track of our iowait state (only updated in phi2 edges)
    reg iowait;

    // For loop indexer
    integer i;

    always @(posedge phi0)
    begin
        phi2 <= !phi2; // Clock divide by 2
    end

    always @(posedge ior) // Make ior edge triggered
    begin
        iordy <= 1;
    end

    wire ramdev;
    assign ramdev = up_addr >= 3'b100 && up_addr <= 3'b110;

    always @(posedge phi2)
    begin
        phi2_s = 1;

        if (!iowait) begin
            // Outside of a wait state, process levels now.
            ram0 <= !(up_addr >= 3'b000 && up_addr <= 3'b011);
            ram1 <= !(ramdev && mid_addr != 2'd11);
            rom  <= 1;

            if (up_addr == 3'b111) begin
                rom <= 0;
                //iowait <= 1; // Need a way to start a counter, ROM can't notify us when it's ready.
            end else if (vda && ramdev && mid_addr == 2'd11) begin
                iowait <= 1;

                for (i = 0; i < 8; i = i + 1) begin
                    dev[i] <= low_addr != i;
                end
            end else begin
                dev = 8'b11111111;
            end
        end
    end

    always @(negedge phi2)
    begin
        if (iowait) begin
            // We're in a wait phase, see if we need to clear it.
            if (iordy) begin
                // Clear triggered
                iowait <= 0;
                iordy <= 0;
                phi2_s <= 0;
            end
        end else begin
            phi2_s <= 0; // Clear phi2_s when not in wait state.
        end
    end

    assign rd = !(phi0 & rwb);
    assign wr = !(phi0 & !rwb);
endmodule