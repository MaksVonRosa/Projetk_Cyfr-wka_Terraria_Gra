module boss_move (
    input  logic clk,
    input  logic rst,
    input  logic frame_tick,
    input  logic [1:0] game_active,
    input  logic [11:0] char_x,
    input  logic [11:0] player_2_x,
    input  logic [3:0]  player_2_aggro,
    input  logic [3:0]  char_aggro,
    output logic [11:0] boss_x,
    output logic [11:0] boss_y
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam GROUND_Y     = VER_PIXELS - 52 - BOSS_HGT;
    localparam JUMP_HEIGHT  = 350;
    localparam JUMP_SPEED   = 9;
    localparam FALL_SPEED   = 9;
    localparam MOVE_STEP    = 5;
    localparam integer WAIT_TICKS = 30;
    localparam BOSS_START_X = HOR_PIXELS - (HOR_PIXELS/4);  
    logic is_jumping, is_jumping_next;
    logic going_up, going_up_next;
    logic [11:0] jump_peak, jump_peak_next;
    logic [31:0] wait_counter, wait_counter_next;
    logic jump_dir, jump_dir_next;
    logic [11:0] target_x;
    logic [11:0] boss_x_next, boss_y_next;
    
    always_comb begin
        target_x = (player_2_aggro > char_aggro) ? player_2_x : char_x;
        boss_x_next = boss_x;
        boss_y_next = boss_y;
        is_jumping_next = is_jumping;
        going_up_next = going_up;
        jump_peak_next = jump_peak;
        wait_counter_next = wait_counter;
        jump_dir_next = jump_dir;

        if (rst || !game_active) begin
            boss_x_next = BOSS_START_X;
            boss_y_next = GROUND_Y;
            is_jumping_next = 0;
            going_up_next = 0;
            jump_peak_next = GROUND_Y - JUMP_HEIGHT;
            wait_counter_next = 0;
            jump_dir_next = 1;
        end
        else if (frame_tick && game_active == 1) begin
            if (!is_jumping && boss_y == GROUND_Y) begin
                if (wait_counter > 0) begin
                    wait_counter_next = wait_counter - 1;
                end else begin
                    is_jumping_next = 1;
                    going_up_next = 1;
                    jump_peak_next = boss_y - JUMP_HEIGHT;
                    wait_counter_next = WAIT_TICKS;
                    jump_dir_next = (target_x < boss_x) ? 0 : 1;
                end
            end
            if (is_jumping) begin
                if (going_up) begin
                    if (boss_y > jump_peak + JUMP_SPEED)
                        boss_y_next = boss_y - JUMP_SPEED;
                    else
                        going_up_next = 0;
                end 
                else begin
                    if (boss_y < GROUND_Y)
                        boss_y_next = boss_y + FALL_SPEED;
                    else begin
                        boss_y_next = GROUND_Y;
                        is_jumping_next = 0;
                        wait_counter_next = WAIT_TICKS;
                    end
                end
                if (jump_dir == 0 && boss_x > BOSS_LNG + MOVE_STEP)
                    boss_x_next = boss_x - MOVE_STEP;
                else if (jump_dir == 1 && boss_x < HOR_PIXELS - BOSS_LNG - MOVE_STEP)
                    boss_x_next = boss_x + MOVE_STEP;
            end
        end
    end

    always_ff @(posedge clk) begin
        boss_x <= boss_x_next;
        boss_y <= boss_y_next;
        is_jumping <= is_jumping_next;
        going_up <= going_up_next;
        jump_peak <= jump_peak_next;
        wait_counter <= wait_counter_next;
        jump_dir <= jump_dir_next;
    end

endmodule