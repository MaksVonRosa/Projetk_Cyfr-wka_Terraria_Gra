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
// wire [11:0] X_RECT = xpos;
// wire [11:0] Y_RECT = ypos;
//vga_if vga_dr_mouse_2_MouseDisplay_if();


logic [11:0] rgb_mouse;
logic enable_mouse;
logic [11:0] xpos_mouse_limit, ypos_mouse_limit;

/**
 * Internal logic
 */


always_ff @(posedge clk) begin : rect_ff_blk

    if (rst) begin
        vga_out_mouse.vsync  <= '0;
        vga_out_mouse.vblnk  <= '0;
        vga_out_mouse.hsync  <= '0;
        vga_out_mouse.hblnk  <= '0;
        vga_out_mouse.vcount <= '0;
        vga_out_mouse.hcount <= '0;
        vga_out_mouse.rgb    <= '0;


    end else begin
        vga_out_mouse.vsync    <= vga_in_mouse.vsync;
        vga_out_mouse.vblnk    <= vga_in_mouse.vblnk;
        vga_out_mouse.hsync    <= vga_in_mouse.hsync;
        vga_out_mouse.hblnk    <= vga_in_mouse.hblnk;
        vga_out_mouse.vcount   <= vga_in_mouse.vcount;
        vga_out_mouse.hcount   <= vga_in_mouse.hcount;
        vga_out_mouse.rgb   <= rgb_mouse;



    end
end



always_comb begin
    if (xpos > HOR_PIXELS - 1)
        xpos_mouse_limit = HOR_PIXELS - 1;
    else
        xpos_mouse_limit = xpos;

    if (ypos > VER_PIXELS - 1)
        ypos_mouse_limit = VER_PIXELS - 1;
    else
        ypos_mouse_limit = ypos;
end

MouseDisplay inst(
    .pixel_clk(clk),

    .xpos(xpos_mouse_limit),
    .ypos(ypos_mouse_limit),

    .vcount(vga_in_mouse.vcount),
    .hcount(vga_in_mouse.hcount),
    .rgb_in(vga_in_mouse.rgb),
    .rgb_out(rgb_mouse),

    .blank(vga_in_mouse.vblnk | vga_in_mouse.hblnk),

    .enable_mouse_display_out(enable_mouse)


);

endmodule