//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   weapon_draw
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:  Module for drawing melee weapon and its collision with boss 
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

    initial $readmemh("../GameSprites/Melee_wpn.dat", melee_wpn_rom);

    logic [11:0] rel_x;
    logic [11:0] rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr; 

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
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