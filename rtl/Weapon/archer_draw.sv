//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   archer_draw
 Author:        Damian Szczepaniak
 Description:   Module for drawing archer weapon
 */
//////////////////////////////////////////////////////////////////////////////
module archer_draw (
    input  logic        clk,
    input  logic        rst,
    input  logic        mouse_clicked,
    input  logic [1:0]  game_active,
    input  logic [1:0]  char_class,
    input  logic [11:0] pos_x_archer_offset,
    input  logic [11:0] pos_y_archer_offset,
    input  logic        flip_hor_archer,
    input  logic        alive,
    
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam ARCHER_IMG_WIDTH  = 40;
    localparam ARCHER_IMG_HEIGHT = 31;
    localparam ARCHER_WPN_HGT   = 26;
    localparam ARCHER_WPN_LNG   = ARCHER_IMG_WIDTH/2; 

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] archer_wpn_rom [0:ARCHER_IMG_WIDTH*ARCHER_IMG_HEIGHT-1];
    initial $readmemh("../../GameSprites/Archer_wpn.dat", archer_wpn_rom);

    // Registered inputs
    logic [10:0] vga_hcount, vga_vcount;
    logic vga_hblnk, vga_vblnk;
    logic [11:0] vga_rgb_in;
    
    // Precomputed values
    logic [11:0] x_min, x_max, y_min, y_max;
    logic in_archer_range;
    
    // Pipeline registers
    logic [11:0] rel_x_ff, rel_y_ff;
    logic draw_archer_ff;
    logic [11:0] rgb_nxt_ff;
    
    // Combinatorial signals (USUNIĘTO rejestry)
    logic [15:0] rom_addr_comb;
    logic [11:0] pixel_color_comb;

//------------------------------------------------------------------------------
// Input registration
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        vga_hcount <= '0;
        vga_vcount <= '0;
        vga_hblnk <= '0;
        vga_vblnk <= '0;
        vga_rgb_in <= '0;
    end else begin
        vga_hcount <= vga_in.hcount;
        vga_vcount <= vga_in.vcount;
        vga_hblnk <= vga_in.hblnk;
        vga_vblnk <= vga_in.vblnk;
        vga_rgb_in <= vga_in.rgb;
    end
end

//------------------------------------------------------------------------------
// Precomputation stage
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        x_min <= '0; x_max <= '0;
        y_min <= '0; y_max <= '0;
        in_archer_range <= '0;
    end else begin
        x_min <= pos_x_archer_offset - ARCHER_WPN_LNG;
        x_max <= pos_x_archer_offset + ARCHER_WPN_LNG;
        y_min <= pos_y_archer_offset - ARCHER_WPN_HGT;
        y_max <= pos_y_archer_offset + ARCHER_WPN_HGT;
        
        in_archer_range <= mouse_clicked && game_active && alive && (char_class == 2) &&
                          !vga_vblnk && !vga_hblnk &&
                          (vga_hcount >= x_min) && (vga_hcount < x_max) &&
                          (vga_vcount >= y_min) && (vga_vcount < y_max);
    end
end

//------------------------------------------------------------------------------
// Combinatorial ROM address and pixel color calculation
//------------------------------------------------------------------------------
always_comb begin
    rom_addr_comb = rel_y_ff * ARCHER_IMG_WIDTH + rel_x_ff;
    pixel_color_comb = archer_wpn_rom[rom_addr_comb];
end

//------------------------------------------------------------------------------
// Drawing pipeline stage
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        rel_x_ff <= '0;
        rel_y_ff <= '0;
        draw_archer_ff <= '0;
        rgb_nxt_ff <= '0;
    end else begin
        draw_archer_ff <= in_archer_range;
        
        if (in_archer_range) begin
            rel_y_ff <= vga_vcount - y_min;
            if (flip_hor_archer) begin
                rel_x_ff <= (ARCHER_IMG_WIDTH - 1) - (vga_hcount - x_min);
            end else begin
                rel_x_ff <= vga_hcount - x_min;
            end
        end
        
        // Default value
        rgb_nxt_ff <= vga_rgb_in;
        
        if (draw_archer_ff && rel_x_ff < ARCHER_IMG_WIDTH && rel_y_ff < ARCHER_IMG_HEIGHT) begin
            if (pixel_color_comb != 12'hF00) begin
                rgb_nxt_ff <= pixel_color_comb;
            end
        end
    end
end


//------------------------------------------------------------------------------
// Output assignment
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