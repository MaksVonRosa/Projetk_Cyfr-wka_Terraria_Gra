module boss_draw (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam BOSS_HGT    = 95;
    localparam BOSS_LNG    = 106;
    localparam IMG_WIDTH   = 212;
    localparam IMG_HEIGHT  = 191;

    localparam GROUND_Y    = VER_PIXELS - 52 - BOSS_HGT;
    localparam JUMP_HEIGHT = 350;
    localparam JUMP_SPEED  = 9;
    localparam FALL_SPEED  = 9;
    localparam MOVE_STEP   = 5;

    localparam integer FRAME_TICKS = 65_000_000 / 60;
    localparam integer WAIT_TICKS  = 40;

    logic [11:0] boss_x_pos, boss_y_pos;
    logic [11:0] rgb_nxt;
    logic [8:0]  rel_x, rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr;

    logic is_jumping;
    logic going_up;
    logic [11:0] jump_peak;

    logic jump_dir;

    logic [20:0] tick_count;
    logic frame_tick;
    logic [7:0] wait_counter;

    logic [11:0] boss_rom [0:IMG_WIDTH*IMG_HEIGHT-1];
    initial $readmemh("../GameSprites/Boss.dat", boss_rom);

    always_ff @(posedge clk) begin
        if (tick_count == FRAME_TICKS - 1) begin
            tick_count <= 0;
            frame_tick <= 1;
        end else begin
            tick_count <= tick_count + 1;
            frame_tick <= 0;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            boss_x_pos <= HOR_PIXELS / 4;
            boss_y_pos <= GROUND_Y;
            is_jumping <= 0;
            going_up <= 0;
            jump_peak <= GROUND_Y - JUMP_HEIGHT;
            wait_counter <= 0;
            jump_dir <= 1;
        end else if (frame_tick) begin
            if (!is_jumping && boss_y_pos == GROUND_Y) begin
                if (wait_counter > 0) begin
                    wait_counter <= wait_counter - 1;
                end else begin
                    is_jumping <= 1;
                    going_up <= 1;
                    jump_peak <= boss_y_pos - JUMP_HEIGHT;
                    wait_counter <= WAIT_TICKS;
                    if (char_x < boss_x_pos)
                        jump_dir <= 0;
                    else
                        jump_dir <= 1;
                end
            end

            if (is_jumping) begin
                if (going_up) begin
                    if (boss_y_pos > jump_peak + JUMP_SPEED)
                        boss_y_pos <= boss_y_pos - JUMP_SPEED;
                    else
                        going_up <= 0;
                end else begin
                    if (boss_y_pos < GROUND_Y)
                        boss_y_pos <= boss_y_pos + FALL_SPEED;
                    else begin
                        boss_y_pos <= GROUND_Y;
                        is_jumping <= 0;
                        wait_counter <= WAIT_TICKS;
                    end
                end

                if (jump_dir == 0 && boss_x_pos > BOSS_LNG + MOVE_STEP)
                    boss_x_pos <= boss_x_pos - MOVE_STEP;
                else if (jump_dir == 1 && boss_x_pos < HOR_PIXELS - BOSS_LNG - MOVE_STEP)
                    boss_x_pos <= boss_x_pos + MOVE_STEP;
            end
        end
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (!vga_in.vblnk && !vga_in.hblnk &&
            vga_in.hcount >= boss_x_pos - BOSS_LNG &&
            vga_in.hcount <  boss_x_pos + BOSS_LNG &&
            vga_in.vcount >= boss_y_pos - BOSS_HGT &&
            vga_in.vcount <  boss_y_pos + BOSS_HGT) begin

            rel_y = vga_in.vcount - (boss_y_pos - BOSS_HGT);
            rel_x = vga_in.hcount - (boss_x_pos - BOSS_LNG);

            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                rom_addr = rel_y * IMG_WIDTH + rel_x;
                pixel_color = boss_rom[rom_addr];
                if (pixel_color != 12'hF00)
                    rgb_nxt = pixel_color;
            end
        end
    end

    always_ff @(posedge clk) begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.vsync  <= vga_in.vsync;
        vga_out.vblnk  <= vga_in.vblnk;
        vga_out.hcount <= vga_in.hcount;
        vga_out.hsync  <= vga_in.hsync;
        vga_out.hblnk  <= vga_in.hblnk;
        vga_out.rgb    <= rgb_nxt;
    end
endmodule
