/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */

module top_vga (
        input  logic clk,
        input  logic clk100MHz,
        input  logic rst,
        input  logic stepleft,
        input  logic stepright,
        input  logic stepjump,
        inout  logic ps2_clk,
        inout  logic ps2_data,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    // VGA signals from timing
    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    // VGA signals from background
    vga_if vga_if_bg();

    // VGA signals from character
    vga_if vga_if_char();

    // VGA signals from platform
    vga_if vga_plat();

    // Signals from Mouse
    //vga_if vga_if_MouseCtl();

    /**
     * Signals assignments
     */

    assign vs = vga_if_char.vsync;
    assign hs = vga_if_char.hsync;
    assign {r,g,b} = vga_if_char.rgb;
    assign char_x = u_char.u_ctrl.pos_x;
    assign char_y = u_char.u_ctrl.pos_y;
    
    logic [11:0] xpos_MouseCtl;
    logic [11:0] ypos_MouseCtl;
    logic mouse_left;

    /**
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vcount (vcount_tim),
        .vsync  (vsync_tim),
        .vblnk  (vblnk_tim),
        .hcount (hcount_tim),
        .hsync  (hsync_tim),
        .hblnk  (hblnk_tim)
    );
    MouseCtl u_MouseCtl
    (
        .clk(clk100MHz),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl),
        .left(mouse_left)
    );

    draw_bg u_draw_bg (
        .clk,
        .rst,

        .vcount_in  (vcount_tim),
        .vsync_in   (vsync_tim),
        .vblnk_in   (vblnk_tim),
        .hcount_in  (hcount_tim),
        .hsync_in   (hsync_tim),
        .hblnk_in   (hblnk_tim),

        .vga_bg_out (vga_if_bg.out)
    );

    draw_char u_char (
        .clk,
        .rst,
        .stepleft,
        .stepright,
        .stepjump,
        .on_ground(on_ground),
        .vga_char_in (vga_if_bg.in),
        .vga_char_out (vga_if_char.out)
    );

    platform u_platform (
        .clk(clk),
        .rst(rst),
        .char_x(char_x),
        .char_y(char_y),
        .char_hgt(32),
        .vga_in(vga_if_char.in),
        .vga_out(vga_plat.out),
        .on_ground(on_ground)
    );

endmodule
