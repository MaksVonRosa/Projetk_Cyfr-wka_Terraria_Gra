//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   archer_projectile_draw
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Projectile of archer weapon drawing module
 */
//////////////////////////////////////////////////////////////////////////////
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

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam IMG_WIDTH  = 8;
    localparam IMG_HEIGHT = 8;
    localparam PROJ_LNG   = IMG_WIDTH/2;
    localparam PROJ_HGT   = IMG_HEIGHT/2;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] archer_proj_rom [0:IMG_WIDTH*IMG_HEIGHT-1];
    initial $readmemh("../../GameSprites/Archer_projectile.dat", archer_proj_rom);

    // Single stage pipeline
    logic [11:0] rgb_nxt;
    logic [10:0] vcount_ff, hcount_ff;
    logic vsync_ff, hsync_ff, vblnk_ff, hblnk_ff;

    // Precomputed projectile boundaries
    logic [11:0] proj_x_min [0:PROJECTILE_COUNT-1];
    logic [11:0] proj_x_max [0:PROJECTILE_COUNT-1];
    logic [11:0] proj_y_min [0:PROJECTILE_COUNT-1];
    logic [11:0] proj_y_max [0:PROJECTILE_COUNT-1];

    //------------------------------------------------------------------------------
    // Precompute projectile boundaries (combinatorial)
    //------------------------------------------------------------------------------
    always_comb begin
        for (int i = 0; i < PROJECTILE_COUNT; i++) begin
            logic [11:0] pos_x, pos_y;
            pos_x = pos_x_proj[i*12 +: 12];
            pos_y = pos_y_proj[i*12 +: 12];
            
            proj_x_min[i] = pos_x - PROJ_LNG;
            proj_x_max[i] = pos_x + PROJ_LNG;
            proj_y_min[i] = pos_y - PROJ_HGT;
            proj_y_max[i] = pos_y + PROJ_HGT;
        end
    end

    //------------------------------------------------------------------------------
    // Projectile detection (combinatorial)
    //------------------------------------------------------------------------------
    always_comb begin
        logic hit_detect;
        logic [11:0] rel_x, rel_y;
        logic [15:0] rom_addr;
        logic [11:0] pixel_color;
        
        hit_detect = 0;
        rel_x = 0;
        rel_y = 0;
        rom_addr = 0;
        pixel_color = 0;
        
        if (game_active && char_class == 2 && alive &&
            !vga_in.vblnk && !vga_in.hblnk) begin
            
            // Check each projectile
            for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                if (projectile_animated[i]) begin
                    // Check if current pixel is within projectile bounds
                    if (vga_in.hcount >= proj_x_min[i] && 
                        vga_in.hcount < proj_x_max[i] &&
                        vga_in.vcount >= proj_y_min[i] && 
                        vga_in.vcount < proj_y_max[i]) begin
                        
                        rel_y = vga_in.vcount - proj_y_min[i];
                        rel_x = vga_in.hcount - proj_x_min[i];
                        
                        // Apply horizontal flip if needed
                        if (flip_hor_archer) begin
                            rel_x = (IMG_WIDTH-1) - rel_x;
                        end
                        
                        if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                            rom_addr = rel_y * IMG_WIDTH + rel_x;
                            pixel_color = archer_proj_rom[rom_addr];
                            
                            if (pixel_color != 12'h000) begin
                                hit_detect = 1;
                                break; // Only one projectile per pixel
                            end
                        end
                    end
                end
            end
        end
        
        // RGB output
        if (hit_detect) begin
            rgb_nxt = pixel_color;
        end else begin
            rgb_nxt = vga_in.rgb;
        end
    end

    //------------------------------------------------------------------------------
    // Single stage output pipeline
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_ff <= '0;
            hcount_ff <= '0;
            vsync_ff  <= '0;
            hsync_ff  <= '0;
            vblnk_ff  <= '0;
            hblnk_ff  <= '0;
            vga_out.rgb <= '0;
        end else begin
            vcount_ff <= vga_in.vcount;
            hcount_ff <= vga_in.hcount;
            vsync_ff  <= vga_in.vsync;
            hsync_ff  <= vga_in.hsync;
            vblnk_ff  <= vga_in.vblnk;
            hblnk_ff  <= vga_in.hblnk;
            vga_out.rgb <= rgb_nxt;
        end
    end

    // Output assignments
    assign vga_out.vcount = vcount_ff;
    assign vga_out.hcount = hcount_ff;
    assign vga_out.vsync  = vsync_ff;
    assign vga_out.hsync  = hsync_ff;
    assign vga_out.vblnk  = vblnk_ff;
    assign vga_out.hblnk  = hblnk_ff;

endmodule