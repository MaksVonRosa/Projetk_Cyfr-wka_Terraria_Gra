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
        output logic [3:0] b,
        output logic [11:0] char_x, char_y,

        output logic on_ground,
        output logic ground_lvl,
        output logic [11:0] ground_y
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

    // VGA signals from weapon
    vga_if vga_if_wpn();

    // VGA signals from mouse
    vga_if vga_if_mouse();

    /**
     * Signals assignments
     */

    assign vs = vga_if_mouse.vsync;
    assign hs = vga_if_mouse.hsync;
    assign {r,g,b} = vga_if_mouse.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    
    
    logic [11:0] xpos_MouseCtl;
    logic [11:0] ypos_MouseCtl;
    logic mouse_left;
    logic draw_weapon;
    logic wpn_hgt;
    logic wpn_lng;
    //logic on_ground;



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

    //logic mouse_left_raw, mouse_left_sync1, mouse_left_sync2, mouse_left_clk;

    MouseCtl u_MouseCtl
    (
        .clk(clk100MHz),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl),
        .left(mouse_left)
        //.left(mouse_left_raw)
    );

    draw_mouse u_draw_mouse (
        .clk,
        .rst,
        .vga_in_mouse(vga_if_wpn.in),
        .vga_out_mouse(vga_if_mouse.out),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl)

    );
    /*
    // rozwiazanie problemu pomiedzy clockami myszy i rysowania postaci 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mouse_left_sync1 <= 1'b0;
            mouse_left_sync2 <= 1'b0;
        end else begin
            mouse_left_sync1 <= mouse_left_raw;
            mouse_left_sync2 <= mouse_left_sync1;
        end
        end
    assign mouse_left_clk = mouse_left_sync2;

*/

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
        //.draw_weapon(draw_weapon),
        .vga_char_in (vga_hearts.in),
        .vga_char_out (vga_if_char.out)
        //.mouse_left(mouse_left)
    );

    draw_wpn_ctrl u_draw_wpn_ctrl (
        .clk,
        .rst,
        .draw_weapon(draw_weapon),
        .mouse_left(mouse_left)

    );

    wpn_draw_def u_wpn_draw_def (
        .clk(clk),
        .rst(rst),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .draw_enable(draw_weapon),
        .flip_h(flip_h),
        .wpn_hgt(wpn_hgt),
        .wpn_lng(wpn_lng),
        .vga_in(vga_if_char.in),
        .vga_out(vga_if_wpn.out)
    );

endmodule
