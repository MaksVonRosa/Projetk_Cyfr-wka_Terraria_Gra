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
<<<<<<< HEAD
        inout  logic ps2_clk,
        inout  logic ps2_data,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
        output logic [11:0] char_x, char_y

=======
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
>>>>>>> origin/main
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
<<<<<<< HEAD
=======
    wire [3:0] char_hp_out;
>>>>>>> origin/main

    // VGA signals from background
    vga_if vga_if_bg();

    // VGA signals from character
    vga_if vga_if_char();

<<<<<<< HEAD
    // VGA signals from platform
    vga_if vga_plat();

    // Signals from weapon
    //vga_if vga_if_MouseCtl();
    //vga_if vga_wpn();

=======
     // VGA signals from character
    vga_if vga_boss();

    // VGA signals from platform
    vga_if vga_plat();

    // VGA signals from hearts
    vga_if vga_hearts();
>>>>>>> origin/main

    /**
     * Signals assignments
     */

<<<<<<< HEAD
     assign vs = vga_plat.vsync;
     assign hs = vga_plat.hsync;
     assign {r,g,b} = vga_plat.rgb;

    // assign vs = vga_if_char.vsync;
    // assign hs = vga_if_char.hsync;
    // assign {r,g,b} = vga_if_char.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    
    logic [11:0] xpos_MouseCtl;
    logic [11:0] ypos_MouseCtl;
    logic mouse_left;
    logic on_ground;
=======
    assign vs = vga_if_char.vsync;
    assign hs = vga_if_char.hsync;
    assign {r,g,b} = vga_if_char.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    

>>>>>>> origin/main

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

<<<<<<< HEAD
    logic mouse_left_raw, mouse_left_sync1, mouse_left_sync2, mouse_left_clk;

    MouseCtl u_MouseCtl
    (
        .clk(clk100MHz),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl),
        .left(mouse_left_raw)
    );
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


=======
>>>>>>> origin/main
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

<<<<<<< HEAD
=======
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

>>>>>>> origin/main
    draw_char u_char (
        .clk,
        .rst,
        .stepleft,
        .stepright,
        .stepjump,
<<<<<<< HEAD
        .on_ground(on_ground),
        .mouse_left(mouse_left_clk),
        .pos_x_out(pos_x_out),
        .pos_y_out(pos_y_out),
        .vga_char_in (vga_if_bg.in),
        .vga_char_out (vga_if_char.out)
    );

    platform u_platform (
        .clk(clk),
        .rst(rst),
        .char_x(pos_x_out),
        .char_y(pos_y_out),
        .char_hgt(32),
        .vga_in(vga_if_char.in),
        .vga_out(vga_plat.out),
        .on_ground(on_ground)
    );

=======
        .on_ground,
        .ground_lvl,
        .char_hp_out (char_hp_out),
        .pos_x_out (pos_x_out),
        .pos_y_out (pos_y_out),
        .vga_char_in (vga_hearts.in),
        .vga_char_out (vga_if_char.out)
    );

>>>>>>> origin/main
endmodule
