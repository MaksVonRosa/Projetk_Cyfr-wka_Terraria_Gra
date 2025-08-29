//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   boss_top
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Top level boss module integrating movement, HP and rendering
 */
//////////////////////////////////////////////////////////////////////////////
module boss_top (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic player2_game_start,
    input  logic [11:0] char_x,
    input  logic frame_tick,
    input  logic projectile_hit,
    input  logic melee_hit,
    input  logic [11:0] player_2_x,
    input  logic [6:0] boss_out_hp,
    input  logic [3:0] player_2_aggro,
    input  logic [3:0] char_aggro,
    input  logic player_2_data_valid,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic [11:0] boss_x_out,
    output logic [11:0] boss_y_out,
    output logic [11:0] boss_hgt,
    output logic [11:0] boss_lng,
    output logic [6:0]  boss_hp,
    output logic        boss_alive
);
    import vga_pkg::*;
    
    localparam IMG_WIDTH   = 212;
    localparam IMG_HEIGHT  = 191;
    
    vga_if vga_boss_mid();
    logic [10:0] rom_addr;
    logic [11:0] boss_data;
    logic [11:0] boss_x;
    logic [11:0] boss_y;

    read_rom #(
        .ROM_WIDTH(12), 
        .ROM_DEPTH(IMG_WIDTH*IMG_HEIGHT), 
        .FILE_PATH("../../GameSprites/Boss.dat")
    ) boss_rom_inst(
        .addr(rom_addr), 
        .data(boss_data)
    );

    boss_move u_move (
        .clk(clk),
        .rst(rst),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .char_x(char_x),
        .player_2_x(player_2_x),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .char_aggro(char_aggro),
        .player_2_aggro(player_2_aggro)
    );

    boss_hp u_hp (
        .clk(clk),
        .rst(rst),
        .game_active(game_active),
        .game_start(game_start),
        .player2_game_start(player2_game_start),
        .projectile_hit(projectile_hit),
        .melee_hit(melee_hit),
        .boss_hp(boss_hp),
        .player_2_data_valid(player_2_data_valid),
        .boss_out_hp(boss_out_hp),
        .vga_in(vga_in),
        .vga_out(vga_boss_mid.out)
    );

    boss_render u_render (
        .clk(clk),
        .game_active(game_active),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_hp(boss_hp),
        .boss_data(boss_data),
        .rom_addr(rom_addr),
        .boss_alive(boss_alive),
        .vga_in(vga_boss_mid.in),
        .vga_out(vga_out)
    );
    
    assign boss_hgt = 95;  // BOSS_HGT
    assign boss_lng = 106; // BOSS_LNG
    assign boss_x_out = boss_x;
    assign boss_y_out = boss_y;
endmodule