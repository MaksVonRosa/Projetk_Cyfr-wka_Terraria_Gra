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

    // Pipeline registers - STAGE 1: Input registration
    logic [11:0] vga_rgb_ff, vga_hcount_ff, vga_vcount_ff;
    logic vga_vblnk_ff, vga_hblnk_ff;
    logic [1:0] game_active_ff;
    logic [1:0] char_class_ff;
    logic alive_ff;
    logic flip_hor_archer_ff;
    
    // Projectile position registers
    logic [11:0] pos_x_proj_ff [0:PROJECTILE_COUNT-1];
    logic [11:0] pos_y_proj_ff [0:PROJECTILE_COUNT-1];
    logic [PROJECTILE_COUNT-1:0] projectile_animated_ff;

    // Pipeline registers - STAGE 2: Detection logic
    logic hit_detect;
    logic [11:0] rel_x_ff, rel_y_ff;
    logic [15:0] rom_addr_calc;
    logic [11:0] pixel_color_calc;
    
    // Pipeline registers - STAGE 3: RGB output
    logic [11:0] rgb_nxt;

    // Pipeline registers - STAGE 4: Output pipeline (original)
    logic [11:0] rgb_d1, rgb_d2;
    logic [10:0] vcount_d1, hcount_d1, vcount_d2, hcount_d2;
    logic vsync_d1, hsync_d1, vblnk_d1, hblnk_d1;
    logic vsync_d2, hsync_d2, vblnk_d2, hblnk_d2;

    //------------------------------------------------------------------------------
    // STAGE 1: Input registration
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vga_rgb_ff <= '0;
            vga_hcount_ff <= '0;
            vga_vcount_ff <= '0;
            vga_vblnk_ff <= '0;
            vga_hblnk_ff <= '0;
            game_active_ff <= '0;
            char_class_ff <= '0;
            alive_ff <= '0;
            flip_hor_archer_ff <= '0;
            
            for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                pos_x_proj_ff[i] <= '0;
                pos_y_proj_ff[i] <= '0;
            end
            projectile_animated_ff <= '0;
        end else begin
            vga_rgb_ff <= vga_in.rgb;
            vga_hcount_ff <= vga_in.hcount;
            vga_vcount_ff <= vga_in.vcount;
            vga_vblnk_ff <= vga_in.vblnk;
            vga_hblnk_ff <= vga_in.hblnk;
            game_active_ff <= game_active;
            char_class_ff <= char_class;
            alive_ff <= alive;
            flip_hor_archer_ff <= flip_hor_archer;
            
            // Register all projectile positions
            for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                pos_x_proj_ff[i] <= pos_x_proj[i*12 +: 12];
                pos_y_proj_ff[i] <= pos_y_proj[i*12 +: 12];
            end
            projectile_animated_ff <= projectile_animated;
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 2: Projectile detection logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            hit_detect <= 0;
            rel_x_ff <= 0;
            rel_y_ff <= 0;
        end else begin
            hit_detect <= 0;
            rel_x_ff <= 0;
            rel_y_ff <= 0;
            
            if (game_active_ff && char_class_ff == 2 && alive_ff &&
                !vga_vblnk_ff && !vga_hblnk_ff) begin
                
                // Check each projectile sequentially
                for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                    if (projectile_animated_ff[i]) begin
                        // Calculate relative coordinates
                        logic [11:0] rel_x, rel_y;
                        logic in_range;
                        
                        in_range = (vga_hcount_ff >= pos_x_proj_ff[i] - PROJ_LNG) &&
                                   (vga_hcount_ff <  pos_x_proj_ff[i] + PROJ_LNG) &&
                                   (vga_vcount_ff >= pos_y_proj_ff[i] - PROJ_HGT) &&
                                   (vga_vcount_ff <  pos_y_proj_ff[i] + PROJ_HGT);
                        
                        if (in_range) begin
                            rel_y = vga_vcount_ff - (pos_y_proj_ff[i] - PROJ_HGT);
                            rel_x = vga_hcount_ff - (pos_x_proj_ff[i] - PROJ_LNG);
                            
                            // Apply horizontal flip if needed
                            if (flip_hor_archer_ff) 
                                rel_x = (IMG_WIDTH-1) - rel_x;
                            
                            if (rel_x < IMG_WIDTH && rel_y < IMG_HEIGHT) begin
                                hit_detect <= 1;
                                rel_x_ff <= rel_x;
                                rel_y_ff <= rel_y;
                                break; // Only process one projectile per pixel
                            end
                        end
                    end
                end
            end
        end
    end

    // ROM address calculation (combinational)
    always_comb begin
        rom_addr_calc = rel_y_ff * IMG_WIDTH + rel_x_ff;
    end

    // ROM read (combinational)
    always_comb begin
        pixel_color_calc = archer_proj_rom[rom_addr_calc];
    end

    //------------------------------------------------------------------------------
    // STAGE 3: RGB output logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb_nxt <= '0;
        end else begin
            rgb_nxt <= vga_rgb_ff; // Default to background
            
            if (hit_detect && pixel_color_calc != 12'h000) begin
                rgb_nxt <= pixel_color_calc;
            end
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 4: Output pipeline (preserve original timing)
    //------------------------------------------------------------------------------
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
            // Pipeline stage 1
            rgb_d1    <= rgb_nxt;
            vcount_d1 <= vga_in.vcount;
            hcount_d1 <= vga_in.hcount;
            vsync_d1  <= vga_in.vsync;
            hsync_d1  <= vga_in.hsync;
            vblnk_d1  <= vga_in.vblnk;
            hblnk_d1  <= vga_in.hblnk;

            // Pipeline stage 2
            rgb_d2    <= rgb_d1;
            vcount_d2 <= vcount_d1;
            hcount_d2 <= hcount_d1;
            vsync_d2  <= vsync_d1;
            hsync_d2  <= hsync_d1;
            vblnk_d2  <= vblnk_d1;
            hblnk_d2  <= hblnk_d1;

            // Outputs
            vga_out.vcount <= vcount_d2;
            vga_out.hcount <= hcount_d2;
            vga_out.vsync  <= vsync_d2;
            vga_out.hsync  <= hsync_d2;
            vga_out.vblnk  <= vblnk_d2;
            vga_out.hblnk  <= hblnk_d2;
            vga_out.rgb    <= rgb_d2;
        end
    end

endmodule