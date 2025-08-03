/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst,

        input  logic [10:0] vcount_in,
        input  logic        vsync_in,
        input  logic        vblnk_in,
        input  logic [10:0] hcount_in,
        input  logic        hsync_in,
        input  logic        hblnk_in,

        vga_if.out           vga_bg_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;


    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vga_bg_out.vcount <= '0;
            vga_bg_out.vsync  <= '0;
            vga_bg_out.vblnk  <= '0;
            vga_bg_out.hcount <= '0;
            vga_bg_out.hsync  <= '0;
            vga_bg_out.hblnk  <= '0;
            vga_bg_out.rgb    <= '0;
        end else begin
            vga_bg_out.vcount <= vcount_in;
            vga_bg_out.vsync  <= vsync_in;
            vga_bg_out.vblnk  <= vblnk_in;
            vga_bg_out.hcount <= hcount_in;
            vga_bg_out.hsync  <= hsync_in;
            vga_bg_out.hblnk  <= hblnk_in;
            vga_bg_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (vblnk_in || hblnk_in) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else begin                              // Active region:
            if (vcount_in == 0)                     // - top edge:
                rgb_nxt = 12'hf_f_a;                // - - make a yellow line.
            else if (vcount_in == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'hf_0_0;                // - - make a red line.
            else if (hcount_in == 0)                // - left edge:
                rgb_nxt = 12'h0_f_0;                // - - make a green line.
            else if (hcount_in == HOR_PIXELS - 1)   // - right edge
                rgb_nxt = 12'h0_0_f;                // - - make a blue line.

        // 
            

            else if ((hcount_in >= HOR_PIXELS / 3 && hcount_in <= HOR_PIXELS / 3 + 20 && vcount_in >= VER_PIXELS / 3 && vcount_in <= 2 * VER_PIXELS / 3) ||
         (hcount_in >= HOR_PIXELS / 3 && hcount_in <= HOR_PIXELS / 3 + 120 && vcount_in >= VER_PIXELS / 3 && vcount_in <= VER_PIXELS / 3 + 20) ||
         (hcount_in >= HOR_PIXELS / 3 + 120 && hcount_in <= HOR_PIXELS / 3 + 140 && vcount_in >= VER_PIXELS / 3 && vcount_in <= 2 * VER_PIXELS / 3) ||
         (hcount_in >= HOR_PIXELS / 3 + 60 && hcount_in <= HOR_PIXELS / 3 + 80 && vcount_in >= VER_PIXELS / 3 && vcount_in <= 2 * VER_PIXELS / 3 - 80))
                rgb_nxt = 12'ha_0_a;

        // W
            else if ((hcount_in >= HOR_PIXELS / 3 + 160 && hcount_in <= HOR_PIXELS / 3 + 180 && vcount_in >= VER_PIXELS / 3 && vcount_in <= 2 * VER_PIXELS / 3) ||
         (hcount_in >= HOR_PIXELS / 3 + 160 && hcount_in <= HOR_PIXELS / 3 + 280 && vcount_in >= VER_PIXELS / 3 + 180 && vcount_in <= VER_PIXELS / 3 + 200) ||
         (hcount_in >= HOR_PIXELS / 3 + 280 && hcount_in <= HOR_PIXELS / 3 + 300 && vcount_in >= VER_PIXELS / 3  && vcount_in <= 2 * VER_PIXELS / 3) ||
         (hcount_in >= HOR_PIXELS / 3 + 220 && hcount_in <= HOR_PIXELS / 3 + 240 && vcount_in >= VER_PIXELS / 3 + 80 && vcount_in <= 2 * VER_PIXELS / 3))
                rgb_nxt = 12'ha_0_a;

            else if((hcount_in - 400)*(hcount_in - 400) + (vcount_in - 300)*(vcount_in - 300) < 40000)
                rgb_nxt = 12'hf_d_8;

            else                                    // The rest of active display pixels:
                rgb_nxt = 12'ha_a_a;                // - fill with gray.
        end
    end

endmodule
