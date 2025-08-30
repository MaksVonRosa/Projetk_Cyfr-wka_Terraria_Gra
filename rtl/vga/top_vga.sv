//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   top_vga
 Author:        Maksymilian Wiącek, Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Top module integrating every module
 */
//////////////////////////////////////////////////////////////////////////////
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

    //------------------------------------------------------------------------------
    // ROM definitions and signals
    //------------------------------------------------------------------------------
    localparam HEART_W = 10;
    localparam HEART_H = 9;
    localparam IMG_WIDTH = 39;
    localparam IMG_HEIGHT = 53;
    localparam SELECT_W = 250;
    localparam SELECT_H = 75;
    localparam BUTTON_W = 125;
    localparam BUTTON_H = 75;
    localparam BOSS_IMG_WIDTH = 212;
    localparam BOSS_IMG_HEIGHT = 191;
    
    // ROM address and data signals
    logic [10:0] heart_rom_addr, char_rom_addr;
    logic [10:0] selector_rom_addr, selector_rom_addr_select;
    logic [10:0] screen_rom_addr;
    logic [10:0] player2_rom_addr;
    
    logic [11:0] heart_data;
    logic [11:0] archer_data, melee_data;
    logic [11:0] selector_melee_data, selector_archer_data, selector_select_data;
    logic [11:0] screen_start_data, screen_back_data;
    logic [11:0] player2_archer_data, player2_melee_data;
    logic [15:0] boss_rom_addr;
    logic [11:0] boss_data;

    // ROM instances at top level
    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(HEART_W*HEART_H), 
        .FILE_PATH("../GameSprites/Heart.dat")
    ) heart_rom_inst(
        .addr(heart_rom_addr), 
        .data(heart_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Archer.dat")
    ) archer_rom_inst(
        .addr(char_rom_addr), 
        .data(archer_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Melee.dat")
    ) melee_rom_inst(
        .addr(char_rom_addr), 
        .data(melee_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Melee.dat")
    ) selector_melee_rom_inst(
        .addr(selector_rom_addr), 
        .data(selector_melee_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Archer.dat")
    ) selector_archer_rom_inst(
        .addr(selector_rom_addr), 
        .data(selector_archer_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(SELECT_W*SELECT_H), 
        .FILE_PATH("../GameSprites/SELECT_BUTTON.dat")
    ) selector_select_rom_inst(
        .addr(selector_rom_addr_select), 
        .data(selector_select_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(BUTTON_W*BUTTON_H), 
        .FILE_PATH("../GameSprites/START_BUTTON.dat")
    ) screen_start_rom_inst(
        .addr(screen_rom_addr), 
        .data(screen_start_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(BUTTON_W*BUTTON_H), 
        .FILE_PATH("../GameSprites/AGAIN_BUTTON.dat")
    ) screen_back_rom_inst(
        .addr(screen_rom_addr), 
        .data(screen_back_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Archer.dat")
    ) player2_archer_rom_inst(
        .addr(player2_rom_addr), 
        .data(player2_archer_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Melee.dat")
    ) player2_melee_rom_inst(
        .addr(player2_rom_addr), 
        .data(player2_melee_data)
    );

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(BOSS_IMG_WIDTH*BOSS_IMG_HEIGHT), 
        .FILE_PATH("../GameSprites/Boss.dat")
    ) boss_rom_inst(
        .addr(boss_rom_addr), 
        .data(boss_data)
    );

    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    wire [11:0] char_hgt;
    wire [11:0] pos_x_out, pos_y_out;
    wire [11:0] boss_hgt, boss_lng;
    wire [3:0] char_hp;
    wire [3:0] class_aggro;
    wire [11:0] boss_x, boss_y, boss_x_out, boss_y_out;

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
    assign boss_x = boss_x_out;
    assign boss_y = boss_y_out;
    
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
        .start_data(screen_start_data),
        .back_data(screen_back_data),
        .rom_addr(screen_rom_addr),
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
        .melee_data(selector_melee_data),
        .archer_data(selector_archer_data),
        .select_data(selector_select_data),
        .rom_addr(selector_rom_addr),
        .rom_addr_select(selector_rom_addr_select),
        .vga_in(vga_if_menu.in),
        .vga_out(vga_if_selector.out)
    );

    platform u_platform (
        .clk(clk),
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
        .boss_x_out(boss_x_out),
        .boss_y_out(boss_y_out),
        .boss_hgt(boss_hgt),
        .boss_lng(boss_lng),
        .boss_hp(boss_hp),
        .boss_alive(boss_alive),
        .projectile_hit(projectile_hit),
        .boss_data(boss_data),
        .boss_rom_addr(boss_rom_addr),
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
        .player2_game_start(player2_game_start),
        .heart_data(heart_data),
        .archer_data(archer_data),
        .melee_data(melee_data),
        .heart_rom_addr(heart_rom_addr),
        .char_rom_addr(char_rom_addr)
    );

    weapon_top u_weapon_top (
        .clk(clk),
        .rst(rst),
        .pos_x(char_x),
        .pos_y(char_y),
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
        .archer_data(player2_archer_data),
        .melee_data(player2_melee_data),
        .rom_addr(player2_rom_addr),
        .vga_in(vga_if_char.in),
        .vga_out(vga_if_player2.out)
    );

    MouseCtl u_MouseCtl (
        .clk(clk),
        .rst(rst),
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