module draw_char (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,

    vga_if.in vga_char_in,
    vga_if.out vga_char_out
);

    import vga_pkg::*;

    // --- Parametry ---
    localparam CHAR_HGT   = 40;
    localparam CHAR_LNG   = 32;
    localparam CHAR_COL   = 12'h1_5_a;

    localparam HOR_CENTER = HOR_PIXELS / 2;
    localparam GROUND_Y   = VER_PIXELS - 20 - CHAR_HGT;

    localparam JUMP_HEIGHT = 200;
    localparam JUMP_SPEED  = 7;
    localparam FALL_SPEED  = 7;
    localparam MOVE_STEP   = 5;

    // --- Rejestry pozycji ---
    logic [11:0] CHAR_NEXTX, CHAR_NEXTY;
    logic [11:0] draw_x, draw_y;
    logic [11:0] rgb_nxt;

    logic is_jumping;
    logic [11:0] jump_peak;

    // --- Ramka (początek obrazu) ---
    logic frame_tick;
    always_ff @(posedge clk) begin
        frame_tick <= (vga_char_in.vcount == 0 && vga_char_in.hcount == 0);
    end

    // --- Logika ruchu poziomego ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            CHAR_NEXTX <= HOR_CENTER;
        end else if (frame_tick) begin
            if (stepleft && CHAR_NEXTX > CHAR_LNG + MOVE_STEP)
                CHAR_NEXTX <= CHAR_NEXTX - MOVE_STEP;
            else if (stepright && CHAR_NEXTX < HOR_PIXELS - CHAR_LNG - MOVE_STEP)
                CHAR_NEXTX <= CHAR_NEXTX + MOVE_STEP;
        end
    end

    // --- Logika skoku / grawitacji ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            CHAR_NEXTY <= GROUND_Y;
            is_jumping <= 0;
            jump_peak  <= GROUND_Y - JUMP_HEIGHT;
        end else if (frame_tick) begin
            if (!is_jumping && stepjump && CHAR_NEXTY == GROUND_Y) begin
                is_jumping <= 1;
            end

            if (is_jumping) begin
                if (CHAR_NEXTY > jump_peak + JUMP_SPEED)
                    CHAR_NEXTY <= CHAR_NEXTY - JUMP_SPEED;
                else
                    is_jumping <= 0;
            end else begin
                if (CHAR_NEXTY < GROUND_Y - FALL_SPEED)
                    CHAR_NEXTY <= CHAR_NEXTY + FALL_SPEED;
                else
                    CHAR_NEXTY <= GROUND_Y;
            end
        end
    end

    // --- Synchronizacja i buforowanie pozycji ---
    always_ff @(posedge clk) begin
        if (rst) begin
            draw_x <= HOR_CENTER;
            draw_y <= GROUND_Y;
        end else if (frame_tick) begin
            draw_x <= CHAR_NEXTX;
            draw_y <= CHAR_NEXTY;
        end

        // VGA passthrough
        vga_char_out.vcount <= vga_char_in.vcount;
        vga_char_out.vsync  <= vga_char_in.vsync;
        vga_char_out.vblnk  <= vga_char_in.vblnk;
        vga_char_out.hcount <= vga_char_in.hcount;
        vga_char_out.hsync  <= vga_char_in.hsync;
        vga_char_out.hblnk  <= vga_char_in.hblnk;
        vga_char_out.rgb    <= rgb_nxt;
    end

    // --- Rysowanie prostokąta ---
    always_ff @(posedge clk) begin
        if (vga_char_in.vblnk || vga_char_in.hblnk) begin
            rgb_nxt <= 12'h000;
        end else if (
            vga_char_in.hcount >= draw_x - CHAR_LNG &&
            vga_char_in.hcount <= draw_x + CHAR_LNG &&
            vga_char_in.vcount >= draw_y - CHAR_HGT &&
            vga_char_in.vcount <= draw_y + CHAR_HGT
        ) begin
            rgb_nxt <= CHAR_COL;
        end else begin
            rgb_nxt <= vga_char_in.rgb;
        end
    end

endmodule

