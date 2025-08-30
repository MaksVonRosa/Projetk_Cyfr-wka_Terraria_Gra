//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   melee_draw
 Author:        Damian Szczepaniak
 Description:   Module for drawing melee weapon with boss collision
 */
//////////////////////////////////////////////////////////////////////////////
module melee_draw (
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
    localparam BOSS_LNG = 32;
    localparam BOSS_HGT = 32;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] melee_wpn_rom [0:MELEE_IMG_WIDTH*MELEE_IMG_HEIGHT-1];
    initial $readmemh("../GameSprites/Melee_wpn.dat", melee_wpn_rom);

    // Registered inputs
    logic [10:0] vga_hcount, vga_vcount;
    logic vga_hblnk, vga_vblnk;
    logic [11:0] vga_rgb_in;
    
    // Precomputed values
    logic [11:0] melee_x_pos, melee_y_pos;
    logic [11:0] x_min, x_max, y_min, y_max;
    logic in_melee_range;
    
    // Pipeline registers
    logic [11:0] rel_x_ff, rel_y_ff;
    logic draw_melee_ff;
    logic [11:0] rgb_nxt_ff;
    logic [15:0] rom_addr;
    // USUNIĘTO: logic [11:0] pixel_color; // Niepotrzebny rejestr

    // Combinatorial signals
    logic [11:0] pixel_color_comb; // Kombinacyjne odczyt z ROM

//------------------------------------------------------------------------------
// Input registration
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
        vga_hcount <= vga_in.hcount;
        vga_vcount <= vga_in.vcount;
        vga_hblnk <= vga_in.hblnk;
        vga_vblnk <= vga_in.vblnk;
        vga_rgb_in <= vga_in.rgb;
end

//------------------------------------------------------------------------------
// Precomputation stage
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        melee_x_pos <= '0;
        melee_y_pos <= '0;
        x_min <= '0; x_max <= '0;
        y_min <= '0; y_max <= '0;
        in_melee_range <= '0;
    end else begin
        melee_x_pos <= pos_x_melee_offset + (flip_hor_melee ? -anim_x_offset : anim_x_offset);
        melee_y_pos <= pos_y_melee_offset;
        
        x_min <= melee_x_pos - MELEE_WPN_LNG;
        x_max <= melee_x_pos + MELEE_WPN_LNG;
        y_min <= melee_y_pos - MELEE_WPN_HGT;
        y_max <= melee_y_pos + MELEE_WPN_HGT;
        
        in_melee_range <= mouse_clicked && game_active && alive && (char_class == 1) &&
                         !vga_vblnk && !vga_hblnk &&
                         (vga_hcount >= x_min) && (vga_hcount < x_max) &&
                         (vga_vcount >= y_min) && (vga_vcount < y_max);
    end
end

//------------------------------------------------------------------------------
// ROM address calculation (combinatorial)
//------------------------------------------------------------------------------
always_comb begin
    rom_addr = rel_y_ff * MELEE_IMG_WIDTH + rel_x_ff;
    pixel_color_comb = melee_wpn_rom[rom_addr];
end

//------------------------------------------------------------------------------
// Drawing pipeline stage
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        rel_x_ff <= '0;
        rel_y_ff <= '0;
        draw_melee_ff <= '0;
        rgb_nxt_ff <= '0;
        melee_hit <= '0;
    end else begin
        draw_melee_ff <= in_melee_range;
        
        if (in_melee_range) begin
            rel_y_ff <= vga_vcount - y_min;
            if (flip_hor_melee) begin
                rel_x_ff <= (MELEE_IMG_WIDTH - 1) - (vga_hcount - x_min);
            end else begin
                rel_x_ff <= vga_hcount - x_min;
            end
        end
        
        // Default values
        rgb_nxt_ff <= vga_rgb_in;
        melee_hit <= '0;
        
        if (draw_melee_ff) begin
            if (rel_x_ff < MELEE_IMG_WIDTH && rel_y_ff < MELEE_IMG_HEIGHT) begin
                if (pixel_color_comb != 12'h02F) begin
                    rgb_nxt_ff <= pixel_color_comb;
                end
            end else if (boss_alive &&
                       rel_x_ff >= (boss_x - BOSS_LNG) && rel_x_ff <= (boss_x + BOSS_LNG) &&
                       rel_y_ff >= (boss_y - BOSS_HGT) && rel_y_ff <= (boss_y + BOSS_HGT)) begin
                melee_hit <= 1'b1;
            end
        end
    end
end

//------------------------------------------------------------------------------
// Output assignment - USUNIĘTO ZBĘDNE REJESTROWANIE
//------------------------------------------------------------------------------

always_ff @(posedge clk) begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.hcount <= vga_in.hcount;
        vga_out.vsync <= vga_in.vsync;
        vga_out.hsync <= vga_in.hsync;
        vga_out.vblnk <= vga_in.vblnk;
        vga_out.hblnk <= vga_in.hblnk;
        vga_out.rgb <= rgb_nxt_ff;
end
endmodule