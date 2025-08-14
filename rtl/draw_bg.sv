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
    if (vblnk_in || hblnk_in) begin
        rgb_nxt = 12'h000;
    end else begin
        // Floor
        if (vcount_in >= (5*VER_PIXELS)/6) begin
<<<<<<< HEAD
            rgb_nxt = 12'h642; // wood base
            if ((vcount_in % 8) < 2)
                rgb_nxt = 12'h420; // plank line
            
            //red carpet
            if (vcount_in >= (5*VER_PIXELS)/6 + 5 && vcount_in <= (5*VER_PIXELS)/6 + 45) begin
                rgb_nxt = 12'hf00; // carpet
                
                if (vcount_in == (5*VER_PIXELS)/6 + 5 || vcount_in == (5*VER_PIXELS)/6 + 45)
                    rgb_nxt = 12'hff0; // gold line

                if ((hcount_in >= 10 && hcount_in <= 12) ||
                    (hcount_in >= HOR_PIXELS - 12 && hcount_in <= HOR_PIXELS - 10))
                    rgb_nxt = 12'hff0; // gold line
            end
        end
        else begin
            rgb_nxt = 12'h666; // stone base
            
            // Brick edges vertical
            if ((((vcount_in / 16) % 2 == 1 ? (hcount_in + 16) : hcount_in) % 32) < 2 ||
                (((vcount_in / 16) % 2 == 1 ? (hcount_in + 16) : hcount_in) % 32) > 29)
                rgb_nxt = 12'h444; // dark edge
            
            // Brick edges horizontal mortar
            else if ((vcount_in % 16) < 2)
                rgb_nxt = 12'h444; // horizontal edge
            
            // Two big arched windows (~64x96 px) at 1/3 and 2/3 width
            if (
                (hcount_in > HOR_PIXELS/3 - 32 && hcount_in < HOR_PIXELS/3 + 32) &&
                (vcount_in > VER_PIXELS/3 && vcount_in < VER_PIXELS/3 + 96) &&
                // Arch top: upper 20 px form semi-circle (radius 32 px)
                (
                    (vcount_in >= VER_PIXELS/3 + 20) || // below arch top
                    (((hcount_in - HOR_PIXELS/3)*(hcount_in - HOR_PIXELS/3) + (vcount_in - (VER_PIXELS/3 + 20))*(vcount_in - (VER_PIXELS/3 + 20))) <= 32*32)
                )
            )
                rgb_nxt = 12'h6cf; // left window
=======
            rgb_nxt = 12'h642;
            if ((vcount_in % 8) < 2)
                rgb_nxt = 12'h420;
            
            //carpet
            if (vcount_in >= (5*VER_PIXELS)/6 + 5 && vcount_in <= (5*VER_PIXELS)/6 + 45) begin
                rgb_nxt = 12'h80a;
                
                if (vcount_in == (5*VER_PIXELS)/6 + 5 || vcount_in == (5*VER_PIXELS)/6 + 45)
                    rgb_nxt = 12'hff0;

                if ((hcount_in >= 10 && hcount_in <= 12) ||
                    (hcount_in >= HOR_PIXELS - 12 && hcount_in <= HOR_PIXELS - 10))
                    rgb_nxt = 12'hff0;
            end
        end
        else begin
            rgb_nxt = 12'h666;
            
            if ((((vcount_in / 16) % 2 == 1 ? (hcount_in + 16) : hcount_in) % 32) < 2 ||
                (((vcount_in / 16) % 2 == 1 ? (hcount_in + 16) : hcount_in) % 32) > 29)
                rgb_nxt = 12'h444;
            
            else if ((vcount_in % 16) < 2)
                rgb_nxt = 12'h444;
            
            // Two big arched windows
            if (
                (hcount_in > HOR_PIXELS/3 - 32 && hcount_in < HOR_PIXELS/3 + 32) &&
                (vcount_in > VER_PIXELS/3 && vcount_in < VER_PIXELS/3 + 96) &&
                (
                    (vcount_in >= VER_PIXELS/3 + 20) ||
                    (((hcount_in - HOR_PIXELS/3)*(hcount_in - HOR_PIXELS/3) + (vcount_in - (VER_PIXELS/3 + 20))*(vcount_in - (VER_PIXELS/3 + 20))) <= 32*32)
                )
            )
                rgb_nxt = 12'h6cf;
>>>>>>> origin/main
            
            else if (
                (hcount_in > (2*HOR_PIXELS)/3 - 32 && hcount_in < (2*HOR_PIXELS)/3 + 32) &&
                (vcount_in > VER_PIXELS/3 && vcount_in < VER_PIXELS/3 + 96) &&
                (
                    (vcount_in >= VER_PIXELS/3 + 20) ||
                    (((hcount_in - (2*HOR_PIXELS)/3)*(hcount_in - (2*HOR_PIXELS)/3) + (vcount_in - (VER_PIXELS/3 + 20))*(vcount_in - (VER_PIXELS/3 + 20))) <= 32*32)
                )
            )
<<<<<<< HEAD
                rgb_nxt = 12'h6cf; // right window
            
            // Columns positions: 1/6, 1/2, 5/6 screen width, width 30 px
=======
                rgb_nxt = 12'h6cf;
            
            // Columns
>>>>>>> origin/main
            if (
                (hcount_in > HOR_PIXELS/6 - 15 && hcount_in < HOR_PIXELS/6 + 15) ||
                (hcount_in > HOR_PIXELS/2 - 15 && hcount_in < HOR_PIXELS/2 + 15) ||
                (hcount_in > (5*HOR_PIXELS)/6 - 15 && hcount_in < (5*HOR_PIXELS)/6 + 15)
            ) begin
<<<<<<< HEAD
                // 3D shading: lighter left 5 px, darker right 5 px, middle base color
=======
>>>>>>> origin/main
                if (
                    ( (hcount_in > (HOR_PIXELS/6 - 15) && hcount_in <= (HOR_PIXELS/6 - 10)) ||
                      (hcount_in > (HOR_PIXELS/2 - 15) && hcount_in <= (HOR_PIXELS/2 - 10)) ||
                      (hcount_in > ((5*HOR_PIXELS)/6 - 15) && hcount_in <= ((5*HOR_PIXELS)/6 - 10)) )
                )
<<<<<<< HEAD
                    rgb_nxt = 12'h666; // lighter edge
=======
                    rgb_nxt = 12'h666;
>>>>>>> origin/main
                
                else if (
                    ( (hcount_in >= (HOR_PIXELS/6 + 10) && hcount_in < (HOR_PIXELS/6 + 15)) ||
                      (hcount_in >= (HOR_PIXELS/2 + 10) && hcount_in < (HOR_PIXELS/2 + 15)) ||
                      (hcount_in >= ((5*HOR_PIXELS)/6 + 10) && hcount_in < ((5*HOR_PIXELS)/6 + 15)) )
                )
<<<<<<< HEAD
                    rgb_nxt = 12'h222; // darker edge
                
                else
                    rgb_nxt = 12'h444; // column base
                
                // Vertical Greek-style stripes every 4 px inside column (width 30 px)
                if (((hcount_in - (HOR_PIXELS/6 - 15)) % 4 == 1) ||
                    ((hcount_in - (HOR_PIXELS/2 - 15)) % 4 == 1) ||
                    ((hcount_in - ((5*HOR_PIXELS)/6 - 15)) % 4 == 1))
                    rgb_nxt = 12'h222; // stripe
=======
                    rgb_nxt = 12'h222; 
                
                else
                    rgb_nxt = 12'h444;
                
                if (((hcount_in - (HOR_PIXELS/6 - 15)) % 4 == 1) ||
                    ((hcount_in - (HOR_PIXELS/2 - 15)) % 4 == 1) ||
                    ((hcount_in - ((5*HOR_PIXELS)/6 - 15)) % 4 == 1))
                    rgb_nxt = 12'h222;
>>>>>>> origin/main
            end
        end
    end
end



endmodule
