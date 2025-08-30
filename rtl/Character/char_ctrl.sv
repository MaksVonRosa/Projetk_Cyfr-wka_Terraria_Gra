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
    
    logic stepleft_reg, stepright_reg, stepjump_reg;
    logic on_ground_reg;
    logic frame_tick_reg;
    logic [1:0] game_active_reg;

    //------------------------------------------------------------------------------
    // Input registration 
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            stepleft_reg   <= 0;
            stepright_reg  <= 0;
            stepjump_reg   <= 0;
            on_ground_reg  <= 0;
            frame_tick_reg <= 0;
            game_active_reg <= 0;
        end else begin
            stepleft_reg   <= stepleft;
            stepright_reg  <= stepright;
            stepjump_reg   <= stepjump;
            on_ground_reg  <= on_ground;
            frame_tick_reg <= frame_tick;
            game_active_reg <= game_active;
        end
    end

    //------------------------------------------------------------------------------
    // Flip horizontal logic 
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) 
            flip_h <= 0;
        else if (game_active_reg == 1) begin
            if (stepleft_reg)  
                flip_h <= 1;
            else if (stepright_reg) 
                flip_h <= 0;
        end
    end

    //------------------------------------------------------------------------------
    // Horizontal movement logic 
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            next_x <= CHAR_SPAWN;
        end else if (frame_tick_reg && game_active_reg == 1) begin
            case ({stepleft_reg, stepright_reg})
                2'b10: if (next_x > CHAR_LNG + MOVE_STEP)
                          next_x <= next_x - MOVE_STEP;
                2'b01: if (next_x < HOR_PIXELS - CHAR_LNG - MOVE_STEP)
                          next_x <= next_x + MOVE_STEP;
                default: ;
            endcase
        end
    end

    //------------------------------------------------------------------------------
    // Vertical movement and jumping logic 
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            next_y     <= GROUND_Y;
            is_jumping <= 0;
            jump_peak  <= '0;
        end else if (frame_tick_reg && game_active_reg == 1) begin
            // Start jump
            if (stepjump_reg && on_ground_reg && !is_jumping) begin
                is_jumping <= 1;
                jump_peak  <= (next_y > JUMP_HEIGHT) ? (next_y - JUMP_HEIGHT) : 0;
            end
            
            // Jumping logic
            if (is_jumping) begin
                if (next_y > jump_peak) 
                    next_y <= next_y - JUMP_SPEED;
                else 
                    is_jumping <= 0;
            end 
            // Falling logic
            else if (!on_ground_reg && next_y < GROUND_Y) begin
                next_y <= next_y + FALL_SPEED;
                // Clamp to ground level
                if (next_y + FALL_SPEED > GROUND_Y)
                    next_y <= GROUND_Y;
                else
                    next_y <= next_y + FALL_SPEED;
            end
            // Snap to ground if on ground but not at ground level
            else if (on_ground_reg && next_y != GROUND_Y) begin
                next_y <= GROUND_Y;
            end
        end
    end

    //------------------------------------------------------------------------------
    // Output registration
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            pos_x <= CHAR_SPAWN;
            pos_y <= GROUND_Y;
        end else begin
            pos_x <= next_x;
            pos_y <= next_y;
        end
    end

endmodule