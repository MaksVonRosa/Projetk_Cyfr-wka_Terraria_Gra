//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   boss_render
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Boss rendering module with health bar display
 */
//////////////////////////////////////////////////////////////////////////////
module boss_render (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [6:0] boss_hp,
    output logic boss_alive,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam BOSS_HGT    = 95;
    localparam BOSS_LNG    = 106;
    localparam IMG_WIDTH   = 212;
    localparam IMG_HEIGHT  = 191;
    //localparam HP_BAR_WIDTH  = 100;
    //localparam HP_BAR_HEIGHT = 8;
    //localparam HP_START_X    = HOR_PIXELS - HP_BAR_WIDTH - 10;
    //localparam HP_START_Y    = 10;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] rgb_nxt;
    logic [8:0] rel_x, rel_y;
    logic [11:0] pixel_color;
    logic [15:0] rom_addr;
    logic [11:0] boss_rom [0:IMG_WIDTH*IMG_HEIGHT-1];
    logic [11:0] hp_width; 
    logic boss_alive_nxt; 

    initial $readmemh("../../GameSprites/Boss.dat", boss_rom);

    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (game_active == 1 && boss_hp > 0) begin
            boss_alive_nxt = 1;
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
        boss_alive     <= boss_alive_nxt;
    end
endmodule