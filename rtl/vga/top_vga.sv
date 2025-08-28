module top_vga (
    input  logic        clk,
    input  logic        clk100MHz,
    input  logic        rst,
    input  logic        stepleft,
    input  logic        stepright,
    input  logic        stepjump,
    input  logic [11:0] player_2_x,
    input  logic [11:0] player_2_y,
    input  logic [3:0]  player_2_hp,
    input  logic [3:0]  player_2_aggro,
    input  logic        player_2_flip_h,
    input  logic [1:0]  player_2_class,
    input  logic        player2_game_start,
    input  logic [6:0]  boss_out_hp,
    input  logic        player_2_data_valid,
    //input  logic        both_players_ready,
    inout  logic        ps2_clk,
    inout  logic        ps2_data,
    output logic        vs,
    output logic        hs,
    output logic [11:0] char_x,
    output logic [11:0] char_y,
    output logic [3:0] current_health,
    output logic [6:0] boss_hp,
    output logic [3:0] char_aggro,
    output logic [1:0] char_class,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    output logic        flip_h,
    output logic        game_start
);
    timeunit 1ns;
    timeprecision 1ps;

    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    wire [11:0] char_hgt;
    wire [11:0] pos_x_out, pos_y_out;
    wire [11:0] boss_hgt, boss_lng;
    wire [3:0] char_hp;
    wire [3:0] class_aggro;
    wire [11:0] boss_x, boss_y;

    logic frame_tick;
    logic melee_hit;
    logic projectile_hit;
    logic on_ground;
    logic alive;
    logic boss_alive;

    vga_if vga_if_bg();
    vga_if vga_if_char();
    vga_if vga_if_boss();
    vga_if vga_if_plat();
    vga_if vga_if_menu();
    vga_if vga_if_mouse();
    vga_if vga_if_wpn();
    vga_if vga_if_selector();
    vga_if vga_if_player2();

    assign vs = vga_if_mouse.vsync;
    assign hs = vga_if_mouse.hsync;
    assign {r,g,b} = vga_if_mouse.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    logic [11:0] xpos_MouseCtl;
    logic [11:0] ypos_MouseCtl;
    logic mouse_clicked;

    logic [1:0] game_state;
    logic [1:0] game_active;

    game_fsm u_game_fsm (
        .clk(clk),
        .rst(rst),
        .game_start(game_start),
        .player2_game_start(player2_game_start),
        .boss_hp(boss_hp),
        .current_health(current_health),
        .player_2_hp(player_2_hp),
        .game_state(game_state)
    );

    assign game_active = (game_state == 2'd1);

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
        .player_2_data_valid(player_2_data_valid),
        .player_2_class(player_2_class),
        .game_start(game_start),
        .char_class(char_class),
        .vga_in(vga_if_bg.in),
        .vga_out(vga_if_menu.out)
    );

    class_selector u_class_selector (
        .clk(clk),
        .rst(rst),
        .game_active(game_state),
        .mouse_x(xpos_MouseCtl),
        .mouse_y(ypos_MouseCtl),
        .mouse_clicked(mouse_clicked),
        .char_class(char_class),
        .char_hp(char_hp),
        .class_aggro(class_aggro),
        .vga_in(vga_if_menu.in),
        .vga_out(vga_if_selector.out)
    );

    platform u_platform (
        .clk(clk),
        //.rst(rst),
        .char_x(char_x),
        .char_y(char_y),
        .char_hgt(char_hgt),
        .vga_in(vga_if_selector.in),
        .vga_out(vga_if_plat.out),
        .on_ground(on_ground),
        .game_active(game_active)
    );

    boss_top u_boss (
        .clk(clk),
        .rst(rst),
        .char_x(char_x),
        .player_2_x(player_2_x),
        .vga_in(vga_if_plat.in),
        .vga_out(vga_if_boss.out),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_hgt(boss_hgt),
        .boss_lng(boss_lng),
        .boss_hp(boss_hp),
        .boss_alive(boss_alive),
        .projectile_hit(projectile_hit),
        .melee_hit(melee_hit),
        .frame_tick(frame_tick),
        .boss_out_hp(boss_out_hp),
        .game_active(game_active),
        .game_start(game_start),
        .player2_game_start(player2_game_start),
        .char_aggro(char_aggro),
        .player_2_data_valid(player_2_data_valid),
        .player_2_aggro(player_2_aggro)
    );

    char u_char (
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
        .char_hp (char_hp),
        .player_2_hp(player_2_hp),
        .current_health(current_health),
        .char_class(char_class),
        .char_aggro(char_aggro),
        .class_aggro(class_aggro),
        .pos_x_out(pos_x_out),
        .pos_y_out(pos_y_out),
        .char_hgt(char_hgt),
        .char_lng(),
        .flip_h (flip_h),
        .frame_tick(frame_tick),
        .alive(alive),
        .vga_char_in(vga_if_boss.in),
        .vga_char_out(vga_if_char.out),
        .game_active(game_active),
        .game_start(game_start),
        .player2_game_start(player2_game_start)
    );

    weapon_top u_weapon_top (
        .clk,
        .rst,
        .pos_x(pos_x_out),
        .pos_y(pos_y_out),
        .mouse_clicked(mouse_clicked),
        .xpos_MouseCtl(xpos_MouseCtl),
        .ypos_MouseCtl(ypos_MouseCtl),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .char_class(char_class),
        .boss_alive(boss_alive),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .projectile_hit(projectile_hit),
        .melee_hit(melee_hit),
        .alive(alive),
        .vga_in(vga_if_player2.in),
        .vga_out(vga_if_wpn.out)
        


    );
    
    draw_player_2 u_draw_player_2 (
    .clk(clk),
    .rst(rst),
    .player_2_x(player_2_x),
    .player_2_y(player_2_y),
    .player_2_flip_h(player_2_flip_h),
    .game_active(game_state),
    .player_2_class(player_2_class),
    .player_2_data_valid(player_2_data_valid),
    .player_2_hp(player_2_hp),
    .vga_in(vga_if_char.in),
    .vga_out(vga_if_player2.out)
);


    MouseCtl u_MouseCtl (
        .clk(clk100MHz),
        .rst,
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl),
        .left(mouse_clicked)
    );

    draw_mouse u_draw_mouse (
        .clk(clk),
        .rst(rst),
        .vga_in_mouse(vga_if_wpn.in),
        .vga_out_mouse(vga_if_mouse.out),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl)
    );

    tick_gen u_tick_gen(

        .clk(clk),
        .rst(rst),
        .frame_tick(frame_tick)

    );

endmodule
