/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Damian Szczepaniak
 *
 * Description:
 * Draw rectangle.
 */

module draw_mouse (
    input  logic clk,
    input  logic rst,
    input  wire [11:0] xpos,
    input  wire [11:0] ypos,

    vga_if.in vga_in_mouse,
    vga_if.out vga_out_mouse
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local variables and signals
 */

logic [11:0] rgb_mouse;
logic enable_mouse;

// Pipeline registers
logic [11:0] xpos_ff, ypos_ff;
logic vblnk_ff, hblnk_ff, vsync_ff, hsync_ff;
logic [10:0] vcount_ff, hcount_ff; // Changed to 11-bit to match VGA interface
logic [11:0] rgb_ff;

MouseDisplay inst(
    .pixel_clk(clk),
    .xpos(xpos_ff),  // Use registered version directly
    .ypos(ypos_ff),  // Use registered version directly
    .vcount(vcount_ff),
    .hcount(hcount_ff),
    .rgb_in(rgb_ff),
    .rgb_out(rgb_mouse),
    .blank(vblnk_ff | hblnk_ff),
    .enable_mouse_display_out(enable_mouse)
);

// Input registration stage with position limiting
always_ff @(posedge clk) begin
    if (rst) begin
        xpos_ff <= '0;
        ypos_ff <= '0;
        vblnk_ff <= '0;
        hblnk_ff <= '0;
        vsync_ff <= '0;
        hsync_ff <= '0;
        vcount_ff <= '0;
        hcount_ff <= '0;
        rgb_ff <= '0;
    end else begin
        // Position limiting with registered output
        xpos_ff <= (xpos > HOR_PIXELS - 1) ? (HOR_PIXELS - 1) : xpos[10:0]; // Trim to 11-bit if needed
        ypos_ff <= (ypos > VER_PIXELS - 1) ? (VER_PIXELS - 1) : ypos[10:0]; // Trim to 11-bit if needed
        
        vblnk_ff <= vga_in_mouse.vblnk;
        hblnk_ff <= vga_in_mouse.hblnk;
        vsync_ff <= vga_in_mouse.vsync;
        hsync_ff <= vga_in_mouse.hsync;
        vcount_ff <= vga_in_mouse.vcount;
        hcount_ff <= vga_in_mouse.hcount;
        rgb_ff <= vga_in_mouse.rgb;
    end
end

// Output registration stage
always_ff @(posedge clk) begin
    if (rst) begin
        vga_out_mouse.vsync  <= '0;
        vga_out_mouse.vblnk  <= '0;
        vga_out_mouse.hsync  <= '0;
        vga_out_mouse.hblnk  <= '0;
        vga_out_mouse.vcount <= '0;
        vga_out_mouse.hcount <= '0;
        vga_out_mouse.rgb    <= '0;
    end else begin
        vga_out_mouse.vsync  <= vsync_ff;
        vga_out_mouse.vblnk  <= vblnk_ff;
        vga_out_mouse.hsync  <= hsync_ff;
        vga_out_mouse.hblnk  <= hblnk_ff;
        vga_out_mouse.vcount <= vcount_ff;
        vga_out_mouse.hcount <= hcount_ff;
        vga_out_mouse.rgb    <= rgb_mouse; // From MouseDisplay
    end
end

endmodule