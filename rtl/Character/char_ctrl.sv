//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   char_ctrl
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Character control module with movement and jumping
 */
//////////////////////////////////////////////////////////////////////////////
module char_ctrl (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic on_ground,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic player2_game_start,
    input  logic frame_tick,
    output logic [11:0] pos_x,
    output logic [11:0] pos_y,
    output logic flip_h
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam CHAR_HGT    = 27;
    localparam CHAR_LNG    = 19;
    localparam CHAR_SPAWN  = HOR_PIXELS / 5;
    localparam GROUND_Y    = VER_PIXELS - 52 - CHAR_HGT;
    localparam JUMP_HEIGHT = 300;
    localparam JUMP_SPEED  = 7;
    localparam FALL_SPEED  = 5;
    localparam MOVE_STEP   = 5;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] next_x, next_y;
    logic        is_jumping;
    logic [11:0] jump_peak;

    always_ff @(posedge clk) begin
        if (rst) flip_h <= 0;
        else if (game_active == 1) begin
            if (stepleft)  flip_h <= 1;
            else if (stepright) flip_h <= 0;
        end
    end


    always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            next_x <= CHAR_SPAWN;
        end else if (frame_tick && game_active == 1) begin
            if (stepleft && next_x > CHAR_LNG + MOVE_STEP)
                next_x <= next_x - MOVE_STEP;
            else if (stepright && next_x < HOR_PIXELS - CHAR_LNG - MOVE_STEP)
                next_x <= next_x + MOVE_STEP;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            next_y     <= GROUND_Y;
            is_jumping <= 0;
            jump_peak <= '0;
        end else if (frame_tick && game_active == 1) begin
            if (stepjump && on_ground) begin
                is_jumping <= 1;
                jump_peak  <= next_y - JUMP_HEIGHT;
            end
            if (is_jumping) begin
                if (next_y > jump_peak) next_y <= next_y - JUMP_SPEED;
                else is_jumping <= 0;
            end else if (!on_ground && next_y < GROUND_Y) begin
                next_y <= next_y + FALL_SPEED;
            end
        end
    end

    always_ff @(posedge clk) begin
        pos_x <= next_x;
        pos_y <= next_y;
    end
endmodule