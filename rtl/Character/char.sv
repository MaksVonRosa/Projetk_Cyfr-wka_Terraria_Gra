//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   char
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Top level character module integrating control, drawing and health display
 */
//////////////////////////////////////////////////////////////////////////////
module char (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic on_ground,
    input  logic [1:0] char_class,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [11:0] boss_lng,
    input  logic [11:0] boss_hgt,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic player2_game_start,
    input  logic [3:0] char_hp,
    input  logic frame_tick,
    input  logic [3:0] class_aggro,
    input  logic [3:0]  player_2_hp,
    // ROM data inputs from top level
    input  logic [11:0] heart_data,
    input  logic [11:0] archer_data,
    input  logic [11:0] melee_data,
    // ROM address outputs to top level
    output logic [10:0] heart_rom_addr,
    output logic [10:0] char_rom_addr,
    output logic        alive,
    output logic [3:0] char_aggro,
    output logic [3:0] current_health,
    output logic [11:0] pos_x_out,
    output logic [11:0] pos_y_out,
    output logic [11:0] char_lng,
    output logic [11:0] char_hgt,
    output logic flip_h,
    vga_if.in  vga_char_in,
    vga_if.out vga_char_out
);
    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    vga_if vga_char_mid();

    localparam HEART_W = 10;
    localparam HEART_H = 9;
    localparam IMG_WIDTH = 39;
    localparam IMG_HEIGHT = 53;
    
    logic [11:0] pos_x, pos_y;
    assign pos_x_out = pos_x;
    assign pos_y_out = pos_y;
    
    char_ctrl u_ctrl (
        .clk(clk),
        .rst(rst),
        .stepleft(stepleft),
        .stepright(stepright),
        .stepjump(stepjump),
        .on_ground(on_ground),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .flip_h(flip_h),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .game_start(game_start),
        .player2_game_start(player2_game_start)
    );

    char_draw u_draw (
        .clk(clk),
        .rst(rst),
        .current_health(current_health),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .char_hgt(char_hgt),
        .char_lng(char_lng),
        .char_aggro(char_aggro),
        .class_aggro(class_aggro),
        .flip_h(flip_h),
        .archer_data(archer_data),
        .melee_data(melee_data),
        .rom_addr(char_rom_addr),
        .vga_in(vga_char_in),
        .vga_out(vga_char_mid.out),
        .game_active(game_active),
        .alive(alive),
        .char_class(char_class)
    );

    hearts_display u_hearts_display (
        .clk(clk),
        .rst(rst),
        .char_hp(char_hp),
        .char_x(pos_x),
        .char_y(pos_y),
        .char_lng(char_lng),
        .char_hgt(char_hgt),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_lng(boss_lng),
        .boss_hgt(boss_hgt),
        .current_health(current_health),
        .frame_tick(frame_tick),
        .player_2_hp(player_2_hp),
        .heart_data(heart_data),
        .rom_addr(heart_rom_addr),
        .vga_in(vga_char_mid.in),
        .vga_out(vga_char_out),
        .game_active(game_active),
        .game_start(game_start),
        .player2_game_start(player2_game_start)
    );
endmodule