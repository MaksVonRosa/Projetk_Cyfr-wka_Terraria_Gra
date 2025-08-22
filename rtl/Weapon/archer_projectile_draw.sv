module archer_projectile_draw (
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0] pos_x_proj,
    input  logic [11:0] pos_y_proj,
    input  logic        projectile_active,       // czy pocisk ma być rysowany
    input  logic        projectile_animated,       
    input  logic        flip_hor_archer,    // kierunek lotu
    input  logic [1:0]  game_active,
    input  logic [1:0]  char_class,
    input  logic        mouse_clicked,    
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

    // logic [11:0] archer_proj_rom [0:7][0:IMG_WIDTH*IMG_HEIGHT-1];
    // initial begin
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_right.dat",      archer_proj_rom[0]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_up_right.dat",   archer_proj_rom[1]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_up.dat",         archer_proj_rom[2]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_up_left.dat",    archer_proj_rom[3]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_left.dat",       archer_proj_rom[4]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_down_left.dat",  archer_proj_rom[5]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_down.dat",       archer_proj_rom[6]);
    //     $readmemh("../../GameSprites/Projectile/archer_projectile_down_right.dat", archer_proj_rom[7]);
    // end

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
        if (projectile_active  && game_active && projectile_animated && char_class == 2 &&
            !vga_in.vblnk && !vga_in.hblnk &&
            vga_in.hcount >= pos_x_proj - PROJ_LNG &&
            vga_in.hcount <  pos_x_proj + PROJ_LNG &&
            vga_in.vcount >= pos_y_proj - PROJ_HGT &&
            vga_in.vcount <  pos_y_proj + PROJ_HGT) begin

            rel_y = vga_in.vcount - (pos_y_proj - PROJ_HGT);
            rel_x = vga_in.hcount - (pos_x_proj - PROJ_LNG);
            if (flip_hor_archer) rel_x = (IMG_WIDTH-1) - rel_x;

            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                rom_addr = rel_y * IMG_WIDTH + rel_x;
                pixel_color = archer_proj_rom[rom_addr];
                // pixel_color  = archer_proj_rom[direction_sector][rom_addr];
                if (pixel_color != 12'h000) rgb_nxt = pixel_color;
            end
        end
    end
endmodule
