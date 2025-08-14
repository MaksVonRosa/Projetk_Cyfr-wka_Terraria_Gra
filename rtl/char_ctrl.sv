module char_ctrl (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic on_ground,
<<<<<<< HEAD
    input  logic mouse_left,

    output logic [11:0] pos_x,
    output logic [11:0] pos_y,
    output logic draw_weapon,
=======
    output logic [11:0] pos_x,
    output logic [11:0] pos_y,
    output logic [11:0] ground_lvl,
    output logic [3:0] char_hp, 
>>>>>>> origin/main
    output logic flip_h
);
    import vga_pkg::*;

<<<<<<< HEAD
    localparam CHAR_HGT    = 32;
    localparam CHAR_LNG    = 25;
    localparam HOR_CENTER  = HOR_PIXELS / 2;
    localparam GROUND_Y    = VER_PIXELS - 20 - CHAR_HGT;
    localparam JUMP_HEIGHT = 200;
=======
    localparam CHAR_HGT    = 27;
    localparam CHAR_LNG    = 19;
    localparam CHAR_SPAWN  = HOR_PIXELS / 5;
    localparam GROUND_Y    = VER_PIXELS - 52 - CHAR_HGT;
    localparam JUMP_HEIGHT = 300;
>>>>>>> origin/main
    localparam JUMP_SPEED  = 7;
    localparam FALL_SPEED  = 5;
    localparam MOVE_STEP   = 5;

    logic [11:0] next_x, next_y;
    logic        is_jumping;
    logic [11:0] jump_peak;

    localparam integer FRAME_TICKS = 65_000_000 / 60;
    logic [20:0] tick_count;
    logic        frame_tick;

<<<<<<< HEAD
    //logic draw_weapon;



=======
>>>>>>> origin/main
    always_ff @(posedge clk or posedge rst) begin
        if (rst) flip_h <= 0;
        else if (stepleft)  flip_h <= 1;
        else if (stepright) flip_h <= 0;
    end

    always_ff @(posedge clk) begin
        if (tick_count == FRAME_TICKS - 1) begin
            tick_count <= 0;
            frame_tick <= 1;
        end else begin
            tick_count <= tick_count + 1;
            frame_tick <= 0;
        end
    end

    // Left/Right
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
<<<<<<< HEAD
            next_x <= HOR_CENTER;
=======
            next_x <= CHAR_SPAWN;
            char_hp <= 10; 
>>>>>>> origin/main
        end else if (frame_tick) begin
            if (stepleft && next_x > CHAR_LNG + MOVE_STEP)
                next_x <= next_x - MOVE_STEP;
            else if (stepright && next_x < HOR_PIXELS - CHAR_LNG - MOVE_STEP)
                next_x <= next_x + MOVE_STEP;
        end
    end

    // Jump
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            next_y     <= GROUND_Y;
            is_jumping <= 0;
            jump_peak  <= GROUND_Y - JUMP_HEIGHT;
        end else if (frame_tick) begin
<<<<<<< HEAD
            if (!is_jumping && stepjump && next_y == GROUND_Y)
                is_jumping <= 1;

            if (is_jumping) begin
                if (next_y > jump_peak + JUMP_SPEED)
                    next_y <= next_y - JUMP_SPEED;
                else
                    is_jumping <= 0;
            end else begin
                if (next_y < GROUND_Y - FALL_SPEED)
                    next_y <= next_y + FALL_SPEED;
                else
                    next_y <= GROUND_Y;
            end
        end
    end

//Interacting with mouse
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            draw_weapon <= 0;
        end else if (mouse_left) begin
            draw_weapon <= 1;
        end else begin
            draw_weapon <= 0;
        end
=======
    if (!is_jumping && stepjump && on_ground)
        is_jumping <= 1;

    if (is_jumping) begin
        if (next_y > jump_peak + JUMP_SPEED)
            next_y <= next_y - JUMP_SPEED;
        else
            is_jumping <= 0;
    end else begin
        if (!on_ground) begin
            next_y <= next_y + FALL_SPEED;
        end else begin
            next_y <= next_y;
            jump_peak <= pos_y - JUMP_HEIGHT;
        end
    end
end
>>>>>>> origin/main
    end

    assign pos_x = next_x;
    assign pos_y = next_y;
<<<<<<< HEAD
=======
    assign ground_lvl = GROUND_Y;
>>>>>>> origin/main

endmodule
