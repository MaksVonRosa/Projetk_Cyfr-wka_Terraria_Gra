module wpn_draw_melee_def (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] pos_x,
    input  logic [11:0] pos_y,
    input  logic flip_h,
    input  logic mouse_clicked,
    input  logic angle,
    output logic [11:0] wpn_hgt,
    output logic [11:0] wpn_lng,

    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam WPN_HGT   = 26;
    localparam WPN_LNG   = 19; 
    localparam IMG_WIDTH  = 28;
    localparam IMG_HEIGHT = 54;


    logic [11:0] draw_x, draw_y, rgb_nxt;

    logic [11:0] wpn_rom [0:IMG_WIDTH*IMG_HEIGHT-1];

    initial $readmemh("../../GameSprites/Melee_wpn.dat", wpn_rom);

    logic [5:0] rel_x;
    logic [5:0] rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr; 

    // pipeline d1
    logic [11:0] rgb_d1;
    logic [10:0] vcount_d1, hcount_d1;
    logic vsync_d1, hsync_d1, vblnk_d1, hblnk_d1;

    // pipeline d2
    logic [11:0] rgb_d2;
    logic [10:0] vcount_d2, hcount_d2;
    logic vsync_d2, hsync_d2, vblnk_d2, hblnk_d2;

        // deklaracje (na górze modułu)
    logic signed [15:0] dx, dy;
    logic signed [15:0] x_sprite, y_sprite;
    logic signed [15:0] cos_val, sin_val; 

    localparam FP = 10; // fixed point fractional bits
    localparam SCALE = 1 << FP;
function automatic signed [15:0] cos_lut(input logic [8:0] angle_deg);
    case (angle_deg)
        0   : cos_lut =  1*SCALE; // 1.0
        30  : cos_lut =  0.866*SCALE;
        45  : cos_lut =  0.707*SCALE;
        60  : cos_lut =  0.5*SCALE;
        90  : cos_lut =  0;
        120 : cos_lut = -0.5*SCALE;
        135 : cos_lut = -0.707*SCALE;
        150 : cos_lut = -0.866*SCALE;
        180 : cos_lut = -1*SCALE;
        default: cos_lut = 0;
    endcase
endfunction

function automatic signed [15:0] sin_lut(input logic [8:0] angle_deg);
    case (angle_deg)
        0   : sin_lut =  0;
        30  : sin_lut =  0.5*SCALE;
        45  : sin_lut =  0.707*SCALE;
        60  : sin_lut =  0.866*SCALE;
        90  : sin_lut =  1*SCALE;
        120 : sin_lut =  0.866*SCALE;
        135 : sin_lut =  0.707*SCALE;
        150 : sin_lut =  0.5*SCALE;
        180 : sin_lut =  0;
        default: sin_lut = 0;
    endcase
endfunction


    always_ff @(posedge clk) begin
        if (rst) begin
            draw_x <= HOR_PIXELS / 2;
            draw_y <= VER_PIXELS - 20 - WPN_HGT;

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
            draw_x <= pos_x;
            draw_y <= pos_y;

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

            wpn_hgt <= WPN_HGT;
            wpn_lng <= WPN_LNG;
        end
    end

    // logika sprite (jak wcześniej)
    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (mouse_clicked &&
            !vga_in.vblnk && !vga_in.hblnk &&
            vga_in.hcount >= draw_x - WPN_LNG &&
            vga_in.hcount <  draw_x + WPN_LNG &&
            vga_in.vcount >= draw_y - WPN_HGT &&
            vga_in.vcount <  draw_y + WPN_HGT) begin

            dx = vga_in.hcount - draw_x;
            dy = vga_in.vcount - draw_y;

            // pobranie wartości z tablic LUT
            cos_val = cos_lut(angle); 
            sin_val = sin_lut(angle);

            // obliczenia obrotu w przestrzeni sprite'a
            x_sprite = (dx * cos_val + dy * sin_val) >>> FP;
            y_sprite = (-dx * sin_val + dy * cos_val) >>> FP;

            rel_x = x_sprite + IMG_WIDTH/2;
            rel_y = IMG_HEIGHT + y_sprite; 


            // rel_y = vga_in.vcount - (draw_y - WPN_HGT);
            // rel_x = flip_h ? (IMG_WIDTH - 1) - (vga_in.hcount - (draw_x - WPN_LNG)) : 
            //                 (vga_in.hcount - (draw_x - WPN_LNG));

            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                rom_addr = rel_y * IMG_WIDTH + rel_x;
                pixel_color = wpn_rom[rom_addr];
                if (pixel_color != 12'h02F) rgb_nxt = pixel_color;
            end
        end
    end

endmodule
