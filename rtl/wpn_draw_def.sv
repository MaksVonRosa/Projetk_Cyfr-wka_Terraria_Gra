module wpn_draw_def (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] pos_x,
    input  logic [11:0] pos_y,
    input  logic flip_h,
    input  logic draw_enable,
    output logic [11:0] wpn_hgt,
    output logic [11:0] wpn_lng,

    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam WPN_HGT   = 26;
    localparam WPN_LNG   = 19; 
    localparam IMG_WIDTH  = 39;
    localparam IMG_HEIGHT = 53;

    logic [11:0] draw_x, draw_y, rgb_nxt;

    logic [11:0] wpn_rom [0:IMG_WIDTH*IMG_HEIGHT-1];
    initial $readmemh("../GameSprites/Melee.dat", wpn_rom);

    logic [5:0] rel_x;
    logic [5:0] rel_y;
    logic [11:0] pixel_color;
    logic [10:0] rom_addr;

    always_ff @(posedge clk) begin
        if (rst) begin
            // draw_x <= pos_x;
            // draw_y <= pos_y;
        
            draw_x <= HOR_PIXELS / 2;
            draw_y <= VER_PIXELS - 20 - WPN_HGT;
        end else begin
            draw_x <= pos_x;
            draw_y <= pos_y;
        end
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (draw_enable && 
            !vga_in.vblnk && !vga_in.hblnk &&
            vga_in.hcount >= draw_x - WPN_LNG &&
            vga_in.hcount <  draw_x + WPN_LNG &&
            vga_in.vcount >= draw_y - WPN_HGT &&
            vga_in.vcount <  draw_y + WPN_HGT) begin

            rel_y = vga_in.vcount - (draw_y - WPN_HGT);
            rel_x = flip_h ? (IMG_WIDTH - 1) - (vga_in.hcount - (draw_x - WPN_LNG)) : (vga_in.hcount - (draw_x - WPN_LNG));

            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                rom_addr = rel_y * IMG_WIDTH + rel_x;
                pixel_color = wpn_rom[rom_addr];
                if (pixel_color != 12'hF00) rgb_nxt = pixel_color;
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

        wpn_hgt <= WPN_HGT;
        wpn_lng <= WPN_LNG;
    end

endmodule
