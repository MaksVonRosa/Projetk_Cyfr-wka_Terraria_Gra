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
        output logic on_ground,
        output logic vs,
        output logic hs,
        output logic ground_lvl,
        output logic [11:0] ground_y,
        output logic [11:0] char_x,
        output logic [11:0] char_y,
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
    wire [11:0] pos_x_out, pos_y_out;
    wire [3:0] char_hp_out;

    // VGA signals from background
    vga_if vga_if_bg();

    // VGA signals from character
    vga_if vga_if_char();

     // VGA signals from character
    vga_if vga_boss();

    // VGA signals from platform
    vga_if vga_plat();

    // VGA signals from hearts
    vga_if vga_hearts();

    /**
     * Signals assignments
     */

    assign vs = vga_if_char.vsync;
    assign hs = vga_if_char.hsync;
    assign {r,g,b} = vga_if_char.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    


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

    platform u_platform (
        .clk(clk),
        .rst(rst),
        .char_x(char_x),
        .char_y(char_y),
        .char_hgt(32),
        .vga_in(vga_if_bg.in),
        .vga_out(vga_plat.out),
        .ground_y,
        .on_ground
    );

    hearts_display u_hearts_display (
    .clk(clk),
    .rst(rst),
    .char_hp(char_hp_out),
    .vga_in(vga_boss.in),
    .vga_out(vga_hearts.out)
);

    
    boss_draw u_boss_draw (
        .clk     (clk),
        .rst     (rst),
        .char_x(char_x),
        .char_y(char_y),
        .vga_in  (vga_plat.in),
        .vga_out (vga_boss.out)
    );

    draw_char u_char (
        .clk,
        .rst,
        .stepleft,
        .stepright,
        .stepjump,
        .on_ground,
        .ground_lvl,
        .char_hp_out (char_hp_out),
        .pos_x_out (pos_x_out),
        .pos_y_out (pos_y_out),
        .vga_char_in (vga_hearts.in),
        .vga_char_out (vga_if_char.out)
    );

endmodule
