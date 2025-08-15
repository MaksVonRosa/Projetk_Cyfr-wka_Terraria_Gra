module boss_hp (
    input  logic clk,
    input  logic rst,
    input  logic frame_tick,
    input  logic game_active,
    input  logic buttondown,
    output logic [6:0] boss_hp
);
    logic buttondown_sync, buttondown_prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            boss_hp         <= 100;
            buttondown_sync <= 0;
            buttondown_prev <= 0;
        end else if (frame_tick && game_active == 1) begin
            buttondown_sync <= buttondown;
            buttondown_prev <= buttondown_sync;
            if (buttondown_sync && !buttondown_prev && boss_hp > 0)
                boss_hp <= boss_hp - 1;
        end
    end
endmodule
