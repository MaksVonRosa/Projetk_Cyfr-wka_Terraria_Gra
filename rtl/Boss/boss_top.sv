module boss_top (
    input  logic clk,
    input  logic rst,
    input  logic game_active,
    input  logic buttondown,
    input  logic [11:0] char_x,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic [11:0] boss_x,
    output logic [11:0] boss_y,
    output logic [11:0] boss_hgt,
    output logic [11:0] boss_lng,
    output logic [6:0]  boss_hp
);
    import vga_pkg::*;
    //localparam BOSS_HGT = 95;
    //localparam BOSS_LNG = 106;
    localparam IMG_WIDTH   = 212;
    localparam IMG_HEIGHT  = 191;

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
        .boss_x(boss_x),
        .boss_y(boss_y)
    );

    boss_hp u_hp (
        .clk(clk),
        .rst(rst),
        .frame_tick(frame_tick),
        .game_active(game_active),
        .buttondown(buttondown),
        .boss_hp(boss_hp)
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

    assign boss_hgt = IMG_HEIGHT;
    assign boss_lng = IMG_WIDTH;
endmodule
