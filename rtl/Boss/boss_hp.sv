//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   boss_hp
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Coding style: simple, with FPGA sync reset
 Description:  Boss health points management module
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
    output logic [6:0] boss_hp
);

    logic [6:0] boss_hp_temp;

    localparam BOSS_HP = 100;
    

     always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            boss_hp_temp <= BOSS_HP;
        end else if ((melee_hit||projectile_hit) && game_active) begin
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

endmodule