module boss_top (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic buttondown,
    input  logic [11:0] char_x,
    input  logic [11:0] player_2_x,
    input  logic [6:0] boss_out_hp,
    input  logic [3:0] player_2_aggro,
    input  logic [3:0] class_aggro,
    input  logic player_2_data_valid,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic [11:0] boss_x,
    output logic [11:0] boss_y,
    output logic [11:0] boss_hgt,
    output logic [11:0] boss_lng,
    output logic [6:0]  boss_hp
);
    import vga_pkg::*;
    localparam BOSS_HGT = 95;
    localparam BOSS_LNG = 106;

    logic [20:0] tick_count;
    logic frame_tick;

    // Frame tick generator
    localparam integer FRAME_TICKS = 65_000_000 / 60;
    always_ff @(posedge clk) begin
        if (tick_count == FRAME_TICKS - 1) begin
            tick_count <= 0;
            frame_tick <= 1;
        end else begin
            tick_count <= tick_count + 1;
            frame_tick <= 0;
        end
    end

    boss_move u_move (
        .clk(clk),
        .rst(rst),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .char_x(char_x),
        .player_2_x(player_2_x),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .class_aggro(class_aggro),
        .player_2_aggro(player_2_aggro)
    );

    boss_hp u_hp (
        .clk(clk),
        .rst(rst),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .game_start(game_start),
        .buttondown(buttondown),
        .boss_hp(boss_hp),
        .player_2_data_valid(player_2_data_valid),
        .boss_out_hp(boss_out_hp)
    );

    boss_render u_render (
        .clk(clk),
        .rst(rst),
        .game_active(game_active),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_hp(boss_hp),
        .vga_in(vga_in),
        .vga_out(vga_out)
    );

    assign boss_hgt = BOSS_HGT;
    assign boss_lng = BOSS_LNG;
endmodule
