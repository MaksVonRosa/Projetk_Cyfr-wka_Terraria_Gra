//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   boss_hp
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-27
 Description:  Boss health points management module with HP bar rendering
 */
//////////////////////////////////////////////////////////////////////////////
module boss_hp (
    input  logic clk,
    input  logic rst,
    input  logic game_start,
    input  logic player2_game_start,
    input  logic projectile_hit,    
    input  logic melee_hit,  
    input  logic [1:0] game_active,
    input  logic [6:0] boss_out_hp,
    input  logic       player_2_data_valid,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic [6:0] boss_hp
);
    import vga_pkg::*;

    localparam BOSS_HP         = 100;
    localparam HP_BAR_WIDTH    = 100;
    localparam HP_BAR_HEIGHT   = 8;
    localparam HP_START_X      = HOR_PIXELS - HP_BAR_WIDTH - 10;
    localparam HP_START_Y      = 10;

    logic [6:0] boss_hp_temp;
    logic [11:0] hp_width;
    logic [11:0] rgb_nxt;

    always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            boss_hp_temp <= BOSS_HP;
        end else if ((melee_hit || projectile_hit) && game_active == 1) begin
            boss_hp_temp <= boss_hp_temp - 1;
        end
    end

    always_comb begin
        if (player_2_data_valid) begin
            if (boss_hp_temp < boss_out_hp)
                boss_hp = boss_hp_temp;
            else
                boss_hp = boss_out_hp;
        end else begin
            boss_hp = boss_hp_temp;
        end
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;
        if (game_active == 1) begin
            hp_width = HP_BAR_WIDTH * boss_hp / 100;
            if (vga_in.vcount >= HP_START_Y && vga_in.vcount < HP_START_Y + HP_BAR_HEIGHT &&
                vga_in.hcount >= HP_START_X && vga_in.hcount < HP_START_X + hp_width) begin
                rgb_nxt = 12'hF00;
            end
        end
    end

    always_ff @(posedge clk) begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.vsync  <= vga_in.vsync;
        vga_out.vblnk  <= vga_in.vblnk;
        vga_out.hcount <= vga_in.hcount;
        vga_out.hsync  <= vga_in.hsync;
        vga_out.hblnk  <= vga_in.hblnk;
        vga_out.rgb    <= rgb_nxt;
    end

endmodule
