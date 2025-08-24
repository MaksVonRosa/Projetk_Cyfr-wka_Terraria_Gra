module boss_hp (
    input  logic       clk,
    input  logic       rst,
    input  logic       frame_tick,
    input  logic [1:0] game_active,
    input  logic       game_start,
    input  logic       buttondown,
    input  logic [6:0] boss_out_hp,
    input  logic       player_2_data_valid,
    output logic [6:0] boss_hp
);

    logic [6:0] boss_hp_temp;
    logic       buttondown_sync, buttondown_prev;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            boss_hp_temp    <= 100;
            buttondown_sync <= 0;
            buttondown_prev <= 0;
        end else if (game_start == 1) begin
            boss_hp_temp    <= 100;
            buttondown_sync <= 0;
            buttondown_prev <= 0;
        end else if (frame_tick && game_active == 1) begin
            buttondown_sync <= buttondown;
            buttondown_prev <= buttondown_sync;

            if (buttondown_sync && !buttondown_prev && boss_hp_temp > 0)
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
