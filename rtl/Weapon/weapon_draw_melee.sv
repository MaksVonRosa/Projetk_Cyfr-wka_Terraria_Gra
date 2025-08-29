//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   weapon_draw
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:  Module for drawing weapons, melee weapon collides with boss 
 */
//////////////////////////////////////////////////////////////////////////////
module weapon_draw_melee (
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0] pos_x_melee_offset,
    input  logic [11:0] pos_y_melee_offset,
    input  logic        flip_hor_melee,
    input  logic        mouse_clicked,
    input  logic [11:0] anim_x_offset,
    input  logic [1:0]  game_active,
    input  logic [1:0]  char_class,
    input  logic        boss_alive,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic        alive,
    output logic        melee_hit,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam MELEE_IMG_WIDTH  = 54;
    localparam MELEE_IMG_HEIGHT = 28;
    localparam MELEE_WPN_HGT   = 26;
    localparam MELEE_WPN_LNG   = MELEE_IMG_WIDTH/2; 
    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------

    logic [11:0] rgb_nxt;

    logic [11:0] melee_wpn_rom [0:MELEE_IMG_WIDTH*MELEE_IMG_HEIGHT-1];

    initial $readmemh("../../GameSprites/Melee_wpn.dat", melee_wpn_rom);

    logic [11:0] rel_x;
    logic [11:0] rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr; 

    logic [11:0] rgb_d1;
    logic [10:0] vcount_d1, hcount_d1;
    logic vsync_d1, hsync_d1, vblnk_d1, hblnk_d1;

    
    logic [11:0] rgb_d2;
    logic [10:0] vcount_d2, hcount_d2;
    logic vsync_d2, hsync_d2, vblnk_d2, hblnk_d2;


//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------

 //delay 2st

    // always_ff @(posedge clk) begin
    //     if (rst) begin

    //         rgb_d1    <= '0;
    //         vcount_d1 <= '0;
    //         hcount_d1 <= '0;
    //         vsync_d1  <= '0;
    //         hsync_d1  <= '0;
    //         vblnk_d1  <= '0;
    //         hblnk_d1  <= '0;

    //         rgb_d2    <= '0;
    //         vcount_d2 <= '0;
    //         hcount_d2 <= '0;
    //         vsync_d2  <= '0;
    //         hsync_d2  <= '0;
    //         vblnk_d2  <= '0;
    //         hblnk_d2  <= '0;

    //         vga_out.vcount <= '0;
    //         vga_out.hcount <= '0;
    //         vga_out.vsync  <= '0;
    //         vga_out.hsync  <= '0;
    //         vga_out.vblnk  <= '0;
    //         vga_out.hblnk  <= '0;
    //         vga_out.rgb    <= '0;
    //     end else begin

    //         rgb_d1    <= rgb_nxt;
    //         vcount_d1 <= vga_in.vcount;
    //         hcount_d1 <= vga_in.hcount;
    //         vsync_d1  <= vga_in.vsync;
    //         hsync_d1  <= vga_in.hsync;
    //         vblnk_d1  <= vga_in.vblnk;
    //         hblnk_d1  <= vga_in.hblnk;

    //         rgb_d2    <= rgb_d1;
    //         vcount_d2 <= vcount_d1;
    //         hcount_d2 <= hcount_d1;
    //         vsync_d2  <= vsync_d1;
    //         hsync_d2  <= hsync_d1;
    //         vblnk_d2  <= vblnk_d1;
    //         hblnk_d2  <= hblnk_d1;

    //         vga_out.vcount <= vcount_d2;
    //         vga_out.hcount <= hcount_d2;
    //         vga_out.vsync  <= vsync_d2;
    //         vga_out.hsync  <= hsync_d2;
    //         vga_out.vblnk  <= vblnk_d2;
    //         vga_out.hblnk  <= hblnk_d2;
    //         vga_out.rgb    <= rgb_d2;

    //     end
    // end
always_ff @(posedge clk) begin
    if (rst) begin
        vga_out.vcount <= '0;
        vga_out.hcount <= '0;
        vga_out.vsync  <= '0;
        vga_out.hsync  <= '0;
        vga_out.vblnk  <= '0;
        vga_out.hblnk  <= '0;
        vga_out.rgb    <= '0;
    end else begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.hcount <= vga_in.hcount;
        vga_out.vsync  <= vga_in.vsync;
        vga_out.hsync  <= vga_in.hsync;
        vga_out.vblnk  <= vga_in.vblnk;
        vga_out.hblnk  <= vga_in.hblnk;
        vga_out.rgb    <= rgb_nxt;
    end
end


//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
   

    always_comb begin
        rgb_nxt = vga_in.rgb;
        melee_hit = 0;

            if (mouse_clicked && game_active && alive && char_class == 1 && 
                !vga_in.vblnk && !vga_in.hblnk &&
                vga_in.hcount >= pos_x_melee_offset + (flip_hor_melee ? -anim_x_offset : anim_x_offset) - MELEE_WPN_LNG &&
                vga_in.hcount <  pos_x_melee_offset + (flip_hor_melee ? -anim_x_offset : anim_x_offset) + MELEE_WPN_LNG &&
                vga_in.vcount >= pos_y_melee_offset - MELEE_WPN_HGT &&
                vga_in.vcount <  pos_y_melee_offset + MELEE_WPN_HGT) begin

                rel_y = vga_in.vcount - (pos_y_melee_offset - MELEE_WPN_HGT);
                rel_x = vga_in.hcount - (pos_x_melee_offset + (flip_hor_melee ? -anim_x_offset : anim_x_offset) - MELEE_WPN_LNG);

                if (flip_hor_melee) begin
                    rel_x = (MELEE_IMG_WIDTH - 1) - rel_x;
                end
                if (rel_x < MELEE_IMG_WIDTH && rel_y < MELEE_IMG_HEIGHT) begin
                    rom_addr = rel_y * MELEE_IMG_WIDTH + rel_x;
                    pixel_color = melee_wpn_rom[rom_addr];
                    if (pixel_color != 12'h02F) rgb_nxt = pixel_color;
                end else if (boss_alive &&
                                 rel_x >= boss_x-BOSS_LNG && rel_x <= boss_x+BOSS_LNG &&
                                 rel_y >= boss_y-BOSS_HGT && rel_y <= boss_y+BOSS_HGT) begin
                            melee_hit = 1;
                        end
            end
     end
endmodule