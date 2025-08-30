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
    logic [11:0] vga_rgb_pipeline [1:0];
    logic [11:0] vga_hcount_pipeline;
    logic [11:0] vga_vcount_pipeline;
    logic vga_hsync_pipeline;
    logic vga_vsync_pipeline;
    logic vga_hblnk_pipeline;
    logic vga_vblnk_pipeline;
    logic [6:0] boss_hp_reg;
    logic [11:0] hp_width_reg;

    always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            boss_hp_temp <= BOSS_HP;
        end else if ((melee_hit || projectile_hit) && game_active == 1) begin
            boss_hp_temp <= boss_hp_temp - 1;
        end
    end

    always_comb begin
        if (player_2_data_valid) begin
            boss_hp = (boss_hp_temp < boss_out_hp) ? boss_hp_temp : boss_out_hp;
        end else begin
            boss_hp = boss_hp_temp;
        end
    end

    always_ff @(posedge clk) begin
        boss_hp_reg <= boss_hp;
        
        hp_width_reg <= boss_hp_reg;
        vga_hcount_pipeline <= vga_in.hcount;
        vga_vcount_pipeline <= vga_in.vcount;
        vga_hsync_pipeline  <= vga_in.hsync;
        vga_vsync_pipeline  <= vga_in.vsync;
        vga_hblnk_pipeline  <= vga_in.hblnk;
        vga_vblnk_pipeline  <= vga_in.vblnk;
    end

    always_ff @(posedge clk) begin
        if (vga_vcount_pipeline >= HP_START_Y && 
            vga_vcount_pipeline < HP_START_Y + HP_BAR_HEIGHT &&
            vga_hcount_pipeline >= HP_START_X && 
            vga_hcount_pipeline < HP_START_X + HP_BAR_WIDTH) begin
            if (vga_hcount_pipeline < HP_START_X + hp_width_reg) begin
                vga_rgb_pipeline[0] <= 12'hF00;
            end else begin
                vga_rgb_pipeline[0] <= 12'h000;
            end
        end else begin
            vga_rgb_pipeline[0] <= vga_in.rgb;
        end
    end
    always_ff @(posedge clk) begin
        vga_out.hcount <= vga_hcount_pipeline;
        vga_out.vcount <= vga_vcount_pipeline;
        vga_out.hsync  <= vga_hsync_pipeline;
        vga_out.vsync  <= vga_vsync_pipeline;
        vga_out.hblnk  <= vga_hblnk_pipeline;
        vga_out.vblnk  <= vga_vblnk_pipeline;
        vga_out.rgb    <= (game_active == 1) ? vga_rgb_pipeline[0] : vga_in.rgb;
    end

endmodule