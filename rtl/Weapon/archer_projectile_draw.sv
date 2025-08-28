module archer_projectile_draw #(
parameter PROJECTILE_COUNT = vga_pkg::PROJECTILE_COUNT

)(
    input  logic        clk,
    input  logic        rst,
    input  logic [PROJECTILE_COUNT*12-1:0] pos_x_proj,
    input  logic [PROJECTILE_COUNT*12-1:0] pos_y_proj,
    input logic [PROJECTILE_COUNT-1:0] projectile_animated,
    input  logic        flip_hor_archer,    
    input  logic [1:0]  game_active,
    input  logic [1:0]  char_class,
    input  logic alive,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam IMG_WIDTH  = 8;
    localparam IMG_HEIGHT = 8;
    localparam PROJ_LNG   = IMG_WIDTH/2;
    localparam PROJ_HGT   = IMG_HEIGHT/2;

    logic [11:0] archer_proj_rom [0:IMG_WIDTH*IMG_HEIGHT-1];
    initial $readmemh("../../GameSprites/Archer_projectile.dat", archer_proj_rom);

   
    logic [11:0] rgb_nxt, pixel_color;
    logic [11:0] rel_x, rel_y;
    logic [15:0] rom_addr;

    logic [11:0] rgb_d1;
    logic [10:0] vcount_d1, hcount_d1;
    logic vsync_d1, hsync_d1, vblnk_d1, hblnk_d1;

    
    logic [11:0] rgb_d2;
    logic [10:0] vcount_d2, hcount_d2;
    logic vsync_d2, hsync_d2, vblnk_d2, hblnk_d2;

always_ff @(posedge clk) begin
        if (rst) begin

            rgb_d1    <= '0;
            vcount_d1 <= '0;
            hcount_d1 <= '0;
            vsync_d1  <= '0;
            hsync_d1  <= '0;
            vblnk_d1  <= '0;
            hblnk_d1  <= '0;

            rgb_d2    <= '0;
            vcount_d2 <= '0;
            hcount_d2 <= '0;
            vsync_d2  <= '0;
            hsync_d2  <= '0;
            vblnk_d2  <= '0;
            hblnk_d2  <= '0;

            vga_out.vcount <= '0;
            vga_out.hcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.hsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin

            rgb_d1    <= rgb_nxt;
            vcount_d1 <= vga_in.vcount;
            hcount_d1 <= vga_in.hcount;
            vsync_d1  <= vga_in.vsync;
            hsync_d1  <= vga_in.hsync;
            vblnk_d1  <= vga_in.vblnk;
            hblnk_d1  <= vga_in.hblnk;

            rgb_d2    <= rgb_d1;
            vcount_d2 <= vcount_d1;
            hcount_d2 <= hcount_d1;
            vsync_d2  <= vsync_d1;
            hsync_d2  <= hsync_d1;
            vblnk_d2  <= vblnk_d1;
            hblnk_d2  <= hblnk_d1;

            vga_out.vcount <= vcount_d2;
            vga_out.hcount <= hcount_d2;
            vga_out.vsync  <= vsync_d2;
            vga_out.hsync  <= hsync_d2;
            vga_out.vblnk  <= vblnk_d2;
            vga_out.hblnk  <= hblnk_d2;
            vga_out.rgb    <= rgb_d2;

        end
    end


    
    always_comb begin
        rgb_nxt = vga_in.rgb;
        if (game_active && char_class == 2 && alive &&
            !vga_in.vblnk && !vga_in.hblnk) begin

            for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                if (projectile_animated[i]) begin
                    logic [11:0] pos_x_proj_multi, pos_y_proj_multi;
                    pos_x_proj_multi = pos_x_proj[i*12 +: 12];
                    pos_y_proj_multi = pos_y_proj[i*12 +: 12];

                    if (vga_in.hcount >= pos_x_proj_multi - PROJ_LNG &&
                        vga_in.hcount <  pos_x_proj_multi + PROJ_LNG &&
                        vga_in.vcount >= pos_y_proj_multi - PROJ_HGT &&
                        vga_in.vcount <  pos_y_proj_multi + PROJ_HGT) begin

                        rel_y = vga_in.vcount - (pos_y_proj_multi - PROJ_HGT);
                        rel_x = vga_in.hcount - (pos_x_proj_multi - PROJ_LNG);
                        if (flip_hor_archer) rel_x = (IMG_WIDTH-1) - rel_x;

                        if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                            rom_addr    = rel_y * IMG_WIDTH + rel_x;
                            pixel_color = archer_proj_rom[rom_addr];
                            if (pixel_color != 12'h000)
                                rgb_nxt = pixel_color;
                        end
                    end
                end
            end
        end
    end
endmodule
