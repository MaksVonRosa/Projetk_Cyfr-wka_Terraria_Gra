module char_ctrl (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    output logic [11:0] pos_x,
    output logic [11:0] pos_y
);
    import vga_pkg::*;

    localparam CHAR_HGT    = 32;
    localparam CHAR_LNG    = 25;
    localparam HOR_CENTER  = HOR_PIXELS / 2;
    localparam GROUND_Y    = VER_PIXELS - 20 - CHAR_HGT;
    localparam JUMP_HEIGHT = 200;
    localparam JUMP_SPEED  = 7;
    localparam FALL_SPEED  = 5;
    localparam MOVE_STEP   = 5;

    logic [11:0] next_x, next_y;
    logic        is_jumping;
    logic [11:0] jump_peak;

    localparam integer FRAME_TICKS = 65_000_000 / 60;
    logic [20:0] tick_count;
    logic        frame_tick;

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
            next_x <= HOR_CENTER;
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

    assign pos_x = next_x;
    assign pos_y = next_y;

endmodule
