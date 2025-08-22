module boss_hp (
    input  logic clk,
    input  logic rst,
    input  logic frame_tick,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic buttondown,
    input  logic attack_hit,       
    output logic [6:0] boss_hp
);
    logic buttondown_sync, buttondown_prev;

    localparam BOSS_HP = 10;
    // always_ff @(posedge clk or posedge rst) begin
    //     if (rst) begin
    //         boss_hp         <= 100;
    //         buttondown_sync <= 0;
    //         buttondown_prev <= 0;
    //     end else if (game_start == 1) begin
    //         boss_hp         <= 100;
    //         buttondown_sync <= 0;
    //         buttondown_prev <= 0;
    //     end else if (frame_tick && game_active == 1) begin
    //         buttondown_sync <= buttondown;
    //         buttondown_prev <= buttondown_sync;
    //         if (buttondown_sync && !buttondown_prev && boss_hp > 0)
    //             boss_hp <= boss_hp - 1;
    //     end
    // end
     always_ff @(posedge clk) begin
        if (rst) begin
            boss_hp <= BOSS_HP;
        end else if (game_start == 1) begin
            boss_hp <= BOSS_HP;
        end else if (frame_tick && game_active == 1 && boss_hp > 0 && attack_hit) begin
                boss_hp <= boss_hp - 1;
        end
    end
// module boss_hp (
//     input  logic clk,
//     input  logic rst,
//     input  logic frame_tick,
//     input  logic [1:0] game_active,
//     input  logic game_start,
//     input  logic attack_hit,       // sygnał trafienia
//     output logic [6:0] boss_hp
// );
//     localparam COOLDOWN_TICKS = 5; // np. 5 klatek = ~0.08s przy 60Hz
//     logic [3:0] hit_cooldown;

//     always_ff @(posedge clk or posedge rst) begin
//         if (rst) begin
//             boss_hp <= 100;
//             hit_cooldown <= 0;
//         end else if (game_start == 1) begin
//             boss_hp <= 100;
//             hit_cooldown <= 0;
//         end else if (frame_tick && game_active == 1) begin
//             // zmniejsz licznik cooldown jeśli aktywny
//             if (hit_cooldown > 0)
//                 hit_cooldown <= hit_cooldown - 1;

//             // zadawanie obrażeń tylko jeśli boss żyje i cooldown = 0
//             if (attack_hit && boss_hp > 0 && hit_cooldown == 0) begin
//                 boss_hp <= boss_hp - 1;
//                 hit_cooldown <= COOLDOWN_TICKS;
//             end
//         end
//     end
// endmodule


endmodule
