module boss_render (
    input  logic clk,
    input  logic rst,
    input  logic game_active,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [6:0] boss_hp,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam BOSS_HGT    = 95;
    localparam BOSS_LNG    = 106;
    localparam IMG_WIDTH   = 212;
    localparam IMG_HEIGHT  = 191;
    localparam HP_BAR_WIDTH  = 100;
    localparam HP_BAR_HEIGHT = 8;
    localparam HP_START_X    = HOR_PIXELS - HP_BAR_WIDTH - 10;
    localparam HP_START_Y    = 10;

    logic [11:0] rgb_nxt;
    logic [8:0] rel_x, rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr;
    logic [11:0] boss_rom [0:IMG_WIDTH*IMG_HEIGHT-1];
    logic [11:0] hp_width; 

    initial $readmemh("../../GameSprites/Boss.dat", boss_rom);

    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (game_active == 1 && boss_hp > 0) begin
            if (!vga_in.vblnk && !vga_in.hblnk &&
                vga_in.hcount >= boss_x - BOSS_LNG &&
                vga_in.hcount <  boss_x + BOSS_LNG &&
                vga_in.vcount >= boss_y - BOSS_HGT &&
                vga_in.vcount <  boss_y + BOSS_HGT) begin
                rel_y = vga_in.vcount - (boss_y - BOSS_HGT);
                rel_x = vga_in.hcount - (boss_x - BOSS_LNG);
                if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                    rom_addr = rel_y * IMG_WIDTH + rel_x;
                    pixel_color = boss_rom[rom_addr];
                    if (pixel_color != 12'hF00)
                        rgb_nxt = pixel_color;
                end
            end

            hp_width = HP_BAR_WIDTH * boss_hp / 100;
            if (vga_in.vcount >= HP_START_Y && vga_in.vcount < HP_START_Y + HP_BAR_HEIGHT &&
                vga_in.hcount >= HP_START_X && vga_in.hcount < HP_START_X + hp_width) begin
                rgb_nxt = 12'hF00;
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
