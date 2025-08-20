module top_vga (
    input  logic clk,
    input  logic clk100MHz,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic buttondown,
    output logic on_ground,
    inout  logic ps2_clk,
    inout  logic ps2_data,
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

    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;
    wire [11:0] char_hgt, char_lng;
    wire [11:0] pos_x_out, pos_y_out; 
    wire [11:0] pos_x_wpn, pos_y_wpn;
    wire [11:0] boss_x, boss_y, boss_hgt, boss_lng;
    wire [3:0] current_health;
    wire [6:0] boss_hp;
    logic frame_tick;
    logic [20:0] tick_count;

    vga_if vga_if_bg();
    vga_if vga_if_char();
    vga_if vga_if_boss();
    vga_if vga_if_plat();
    vga_if vga_if_menu();
    vga_if vga_if_mouse();
    vga_if vga_if_wpn();



    assign vs = vga_if_mouse.vsync;
    assign hs = vga_if_mouse.hsync;
    assign {r,g,b} = vga_if_mouse.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    logic [11:0] xpos_MouseCtl;
    logic [11:0] ypos_MouseCtl;
    logic mouse_clicked;
    // logic draw_weapon;
    // logic wpn_hgt;
    // logic wpn_lng;
    // logic [11:0] pos_x_wpn_offset;
    // logic [11:0] pos_y_wpn_offset;
    // logic [15:0] angle;
    // logic [11:0] anim_x_offset;


    logic game_start;
    logic back_to_menu;
    logic [1:0] game_state;
    logic [1:0] game_active;
    logic show_menu_end;
    logic flip_h;
    logic flip_hor_melee;
    game_fsm u_game_fsm (
        .clk(clk),
        .rst(rst),
        .game_start(game_start),
        .back_to_menu(back_to_menu),
        .boss_hp(boss_hp),
        .current_health(current_health),
        .game_state(game_state)
    );

    assign game_active = (game_state == 2'd1);
    assign show_menu_end = (game_state == 2'd0 || game_state == 2'd2);

    vga_timing u_vga_timing (
        .clk(clk),
        .rst(rst),
        .vcount(vcount_tim),
        .vsync(vsync_tim),
        .vblnk(vblnk_tim),
        .hcount(hcount_tim),
        .hsync(hsync_tim),
        .hblnk(hblnk_tim)
    );

    draw_bg u_draw_bg (
        .clk(clk),
        .rst(rst),
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .vga_bg_out(vga_if_bg.out)
    );

    game_screen u_game_screen (
        .clk(clk),
        .rst(rst),
        .game_active(game_state),
        .mouse_x(xpos_MouseCtl),
        .mouse_y(ypos_MouseCtl),
        .mouse_clicked(mouse_clicked),
        .game_start(game_start),
        .back_to_menu(back_to_menu),
        .vga_in(vga_if_bg.in),
        .vga_out(vga_if_menu.out)
    );

    platform u_platform (
        .clk(clk),
        .rst(rst),
        .char_x(char_x),
        .char_y(char_y),
        .char_hgt(32),
        .vga_in(vga_if_menu.in),
        .vga_out(vga_if_plat.out),
        .ground_y(ground_y),
        .on_ground(on_ground),
        .game_active(game_active)
    );

    boss_top u_boss (
        .clk(clk),
        .rst(rst),
        .buttondown(buttondown),
        .char_x(char_x),
        .vga_in(vga_if_plat.in),
        .vga_out(vga_if_boss.out),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_hgt(boss_hgt),
        .boss_lng(boss_lng),
        .boss_hp(boss_hp),
        .game_active(game_active),
        .game_start(game_start),
        .frame_tick(frame_tick)
    );

    draw_char u_char (
        .clk(clk),
        .rst(rst),
        .stepleft(stepleft),
        .stepright(stepright),
        .stepjump(stepjump),
        .on_ground(on_ground),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_lng(boss_lng),
        .boss_hgt(boss_hgt),
        .current_health(current_health),
        .pos_x_out(pos_x_out),
        .pos_y_out(pos_y_out),
        .char_hgt(char_hgt),
        .char_lng(char_lng),
        .ground_lvl(ground_lvl),
        .flip_h_out(flip_h),
        .vga_char_in(vga_if_boss.in),
        .vga_char_out(vga_if_char.out),
        .game_active(game_active),
        .game_start(game_start)
    );

    weapon_top u_weapon_top (
        .clk,
        .rst,
        .pos_x(pos_x_out),
        .pos_y(pos_y_out),
        .mouse_clicked(mouse_clicked),
        .xpos_MouseCtl(xpos_MouseCtl),
        .frame_tick(frame_tick),
        .vga_in(vga_if_char.in),
        .vga_out(vga_if_wpn.out)
        


    );
    // draw_wpn_ctrl u_draw_wpn_ctrl (
    //     .clk,
    //     .rst,
    //     .draw_weapon(draw_weapon),
    //     .mouse_clicked(mouse_clicked),
    //     .pos_x(pos_x_out),
    //     .pos_y(pos_y_out),
    //     .xpos_MouseCtl(xpos_MouseCtl),
    //     .flip_hor_melee(flip_hor_melee),
    //     .pos_x_wpn_offset(pos_x_wpn_offset),
    //     .pos_y_wpn_offset(pos_y_wpn_offset)

        
    // );

    // wpn_draw_melee u_wpn_draw_melee (
    //     .clk(clk),
    //     .rst(rst),
    //     .pos_x_wpn(pos_x_out),
    //     .pos_y_wpn(pos_y_out),
    //     .pos_x_wpn_offset(pos_x_wpn_offset),
    //     .pos_y_wpn_offset(pos_y_wpn_offset),
    //     .mouse_clicked(draw_weapon),
    //     .flip_mouse_left_right(flip_mouse_left_right),
    //     .flip_h(flip_h),
    //     .flip_hor_mouse(flip_hor_melee),
    //     .anim_x_offset(anim_x_offset),
    //     .wpn_hgt(wpn_hgt),
    //     .wpn_lng(wpn_lng),
    //     .vga_in(vga_if_char.in),
    //     .vga_out(vga_if_wpn.out)
    // );

    // wpn_melee_attack_anim u_wpn_melee_attack_anim (
    //     .clk(clk),
    //     .rst(rst),
    //     .frame_tick(frame_tick),       
    //     .mouse_clicked(mouse_clicked),
    //     .anim_x_offset(anim_x_offset)
    // );
  
    MouseCtl u_MouseCtl
    (
        .clk(clk100MHz),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl),
        .left(mouse_clicked)
    );

    draw_mouse u_draw_mouse (
        .clk,
        .rst,
        .vga_in_mouse(vga_if_wpn.in),
        .vga_out_mouse(vga_if_mouse.out),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl)
    );
    tick_gen u_tick_gen(

        .clk(clk),
        .rst(rst),
        .tick_count(tick_count),
        .frame_tick(frame_tick)

    );

endmodule
