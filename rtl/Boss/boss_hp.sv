module boss_hp (
    input  logic clk,
    input  logic rst,
    input  logic game_start,
    input  logic projectile_hit,    
    input  logic game_active,   
    output logic [6:0] boss_hp
);

    localparam BOSS_HP = 100;
    
     always_ff @(posedge clk) begin
        if (rst) begin
            boss_hp <= BOSS_HP;
        end else if (game_start == 1) begin
            boss_hp <= BOSS_HP;
        end else if (projectile_hit) begin
                boss_hp <= boss_hp - 1;
        end
     end


endmodule
