module game_screen (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic [1:0] char_class,
    input  logic [11:0] mouse_x,
    input  logic [11:0] mouse_y,
    input  logic        mouse_clicked,
    output logic        game_start,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam RECT_X = (HOR_PIXELS - 125)/2;
    localparam RECT_Y = (VER_PIXELS - 75)/3;
    localparam RECT_W = 125;
    localparam RECT_H = 75;

    localparam integer CLICK_COOLDOWN = 20;

    logic [11:0] rgb_nxt;
    logic [13:0] rom_addr;
    logic [11:0] start_rom [0:9374];
    logic [11:0] back_rom  [0:9374];
    logic [11:0] pixel_color;
    logic [11:0] rel_x, rel_y;
    logic in_rect;

    logic [31:0] wait_counter;

    initial begin
        $readmemh("../GameSprites/START_BUTTON.dat", start_rom);
        $readmemh("../GameSprites/AGAIN_BUTTON.dat",  back_rom);
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;
        in_rect = (vga_in.hcount >= RECT_X && vga_in.hcount < RECT_X+RECT_W &&
                   vga_in.vcount >= RECT_Y && vga_in.vcount < RECT_Y+RECT_H);

        if (in_rect) begin
            rel_x = vga_in.hcount - RECT_X;
            rel_y = vga_in.vcount - RECT_Y;
            rom_addr = rel_y * 125 + rel_x;
            if (game_active == 0)
                pixel_color = start_rom[rom_addr];
            else if (game_active == 2)
                pixel_color = back_rom[rom_addr];
            else
                pixel_color = rgb_nxt;

            if (pixel_color != 12'h000)
                rgb_nxt = pixel_color;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            game_start   <= 0;
            wait_counter <= 0;
        end else begin
            game_start   <= 0;
            if (wait_counter > 0) wait_counter <= wait_counter - 1;

            if (mouse_clicked) begin
                if (game_active == 0 && wait_counter == 0 &&
                    char_class != 0 &&
                    mouse_x >= RECT_X && mouse_x < RECT_X+RECT_W &&
                    mouse_y >= RECT_Y && mouse_y < RECT_Y+RECT_H) begin
                    game_start   <= 1;
                    wait_counter <= CLICK_COOLDOWN;
                end
                if (game_active == 2 && wait_counter == 0 &&
                    mouse_x >= RECT_X && mouse_x < RECT_X+RECT_W &&
                    mouse_y >= RECT_Y && mouse_y < RECT_Y+RECT_H) begin
                    game_start <= 1;
                    wait_counter  <= CLICK_COOLDOWN;
                end
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
