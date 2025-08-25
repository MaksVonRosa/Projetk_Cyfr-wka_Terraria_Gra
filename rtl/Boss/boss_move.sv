module boss_move (
    input  logic clk,
    input  logic rst,
    input  logic frame_tick,
    input  logic [1:0] game_active,
    input  logic [11:0] char_x,
    input  logic [11:0] player_2_x,
    input  logic [3:0]  player_2_aggro,
    input  logic [3:0]  class_aggro,
    output logic [11:0] boss_x,
    output logic [11:0] boss_y
);
    import vga_pkg::*;

    localparam GROUND_Y     = VER_PIXELS - 52 - BOSS_HGT;
    localparam JUMP_HEIGHT  = 350;
    localparam JUMP_SPEED   = 9;
    localparam FALL_SPEED   = 9;
    localparam MOVE_STEP    = 5;
    localparam integer WAIT_TICKS = 30;
    localparam BOSS_START_X = HOR_PIXELS - (HOR_PIXELS/4);  

    logic is_jumping;
    logic going_up;
    logic [11:0] jump_peak;
    logic jump_dir;
    logic [31:0] wait_counter;
    logic [11:0] target_x;

    always_comb begin
        if (player_2_aggro > class_aggro)
            target_x = player_2_x;
        else
            target_x = char_x;
    end

    always_ff @(posedge clk) begin
        if (rst || !game_active) begin
            boss_x       <= BOSS_START_X;
            boss_y       <= GROUND_Y;
            is_jumping   <= 0;
            going_up     <= 0;
            jump_peak    <= GROUND_Y - JUMP_HEIGHT;
            wait_counter <= 0;
            jump_dir     <= 1;

        end else if (frame_tick && game_active == 1) begin
            if (!is_jumping && boss_y == GROUND_Y) begin
                if (wait_counter > 0) begin
                    wait_counter <= wait_counter - 1;
                end else begin
                    is_jumping   <= 1;
                    going_up     <= 1;
                    jump_peak    <= boss_y - JUMP_HEIGHT;
                    wait_counter <= WAIT_TICKS;
                    jump_dir     <= (target_x < boss_x) ? 0 : 1;
                end
            end

            if (is_jumping) begin
                if (going_up) begin
                    if (boss_y > jump_peak + JUMP_SPEED)
                        boss_y <= boss_y - JUMP_SPEED;
                    else
                        going_up <= 0;
                end else begin
                    if (boss_y < GROUND_Y)
                        boss_y <= boss_y + FALL_SPEED;
                    else begin
                        boss_y       <= GROUND_Y;
                        is_jumping   <= 0;
                        wait_counter <= WAIT_TICKS;
                    end
                end

                if (jump_dir == 0 && boss_x > BOSS_LNG + MOVE_STEP)
                    boss_x <= boss_x - MOVE_STEP;
                else if (jump_dir == 1 && boss_x < HOR_PIXELS - BOSS_LNG - MOVE_STEP)
                    boss_x <= boss_x + MOVE_STEP;
            end
        end
    end
endmodule
