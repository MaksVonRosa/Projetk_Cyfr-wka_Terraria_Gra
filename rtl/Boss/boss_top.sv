module boss_top (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic [11:0] char_x,
    input  logic frame_tick,
    input  logic projectile_hit,
    input  logic melee_hit,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic [11:0] boss_x,
    output logic [11:0] boss_y,
    output logic [11:0] boss_hgt,
    output logic [11:0] boss_lng,
    output logic [6:0]  boss_hp,
    output logic        boss_alive
);
    import vga_pkg::*;
    

    boss_move u_move (
        .clk(clk),
        .rst(rst),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .char_x(char_x),
        .boss_x(boss_x),
        .boss_y(boss_y)
    );

    boss_hp u_hp (
        .clk(clk),
        .rst(rst),
        // .game_active(game_active),
        .game_start(game_start),
        .projectile_hit(projectile_hit),
        // .melee_hit(melee_hit),
        .boss_hp(boss_hp)
    );

    boss_render u_render (
        .clk(clk),
        .rst(rst),
        .game_active(game_active),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_hp(boss_hp),
        .boss_alive(boss_alive),
        .vga_in(vga_in),
        .vga_out(vga_out)
    );
    assign boss_hgt = BOSS_HGT;
    assign boss_lng = BOSS_LNG;
endmodule
