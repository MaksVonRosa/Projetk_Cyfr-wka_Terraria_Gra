module draw_player_2 (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] player_2_x,
    input  logic [11:0] player_2_y,
    input  logic        player_2_flip_h,
    input  logic [1:0]  player_2_class,
    input  logic        player_2_data_valid,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam CHAR_HGT   = 26;
    localparam CHAR_LNG   = 19; 
    localparam IMG_WIDTH  = 39;
    localparam IMG_HEIGHT = 53;

    logic [11:0] draw_x, draw_y;
    logic [11:0] archer_rom [0:IMG_WIDTH*IMG_HEIGHT-1];

    initial begin
        $readmemh("../../GameSprites/Archer.dat", archer_rom);
    end

    logic [5:0] rel_x; 
    logic [5:0] rel_y;
    logic [11:0] pixel_color;
    logic [10:0] rom_addr;
    logic initialized;

    always_ff @(posedge clk) begin
        if (rst) begin
            draw_x <= 0;
            draw_y <= 0;
            initialized <= 0;
        end else if (player_2_data_valid && (player_2_x != 0 || player_2_y != 0)) begin
            draw_x <= player_2_x;
            draw_y <= player_2_y;
            initialized <= 1;
        end
    end

    always_comb begin
        logic [11:0] rgb_nxt;
        rgb_nxt = vga_in.rgb;

        if (initialized &&
            !vga_in.vblnk && !vga_in.hblnk &&
            vga_in.hcount >= draw_x - CHAR_LNG &&
            vga_in.hcount <  draw_x + CHAR_LNG &&
            vga_in.vcount >= draw_y - CHAR_HGT &&
            vga_in.vcount <  draw_y + CHAR_HGT) begin

            rel_y = vga_in.vcount - (draw_y - CHAR_HGT);
            rel_x = player_2_flip_h ? (IMG_WIDTH - 1) - (vga_in.hcount - (draw_x - CHAR_LNG)) :
                                     (vga_in.hcount - (draw_x - CHAR_LNG));

            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                rom_addr = rel_y * IMG_WIDTH + rel_x;
                pixel_color = archer_rom[rom_addr];

                if (pixel_color != 12'hF00)
                    rgb_nxt = pixel_color;
            end
        end
        vga_out.rgb = rgb_nxt;
    end

    always_ff @(posedge clk) begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.vsync  <= vga_in.vsync;
        vga_out.vblnk  <= vga_in.vblnk;
        vga_out.hcount <= vga_in.hcount;
        vga_out.hsync  <= vga_in.hsync;
        vga_out.hblnk  <= vga_in.hblnk;
    end
endmodule
