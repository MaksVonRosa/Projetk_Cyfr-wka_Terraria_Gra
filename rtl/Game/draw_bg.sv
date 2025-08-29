/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst,

        input  logic [10:0] vcount_in,
        input  logic        vsync_in,
        input  logic        vblnk_in,
        input  logic [10:0] hcount_in,
        input  logic        hsync_in,
        input  logic        hblnk_in,

        vga_if.out           vga_bg_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local variables and signals
     */
    
    // Pipeline registers
    logic [10:0] vcount_ff, hcount_ff;
    logic vblnk_ff, hblnk_ff;
    logic [11:0] rgb_ff;
    
    // Pre-calculated values
    logic [10:0] floor_threshold;
    logic [10:0] window1_center_x, window2_center_x;
    logic [10:0] window_center_y;
    logic [10:0] column1_x, column2_x, column3_x;
    
    // Detection signals
    logic is_floor_ff;
    logic is_carpet_ff;
    logic is_window1_ff, is_window2_ff;
    logic is_column1_ff, is_column2_ff, is_column3_ff;
    logic is_grid_pattern_ff;
    logic is_wall_ff;

    //------------------------------------------------------------------------------
    // STAGE 1: Input registration and pre-calculation
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vcount_ff <= 0;
            hcount_ff <= 0;
            vblnk_ff <= 0;
            hblnk_ff <= 0;
        end else begin
            vcount_ff <= vcount_in;
            hcount_ff <= hcount_in;
            vblnk_ff <= vblnk_in;
            hblnk_ff <= hblnk_in;
            
            // Pre-calculate constants
            floor_threshold <= (5 * VER_PIXELS) / 6;
            window1_center_x <= HOR_PIXELS / 3;
            window2_center_x <= (2 * HOR_PIXELS) / 3;
            window_center_y <= VER_PIXELS / 3 + 20;
            column1_x <= HOR_PIXELS / 6;
            column2_x <= HOR_PIXELS / 2;
            column3_x <= (5 * HOR_PIXELS) / 6;
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 2: Region detection (pipelined)
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            is_floor_ff <= 0;
            is_carpet_ff <= 0;
            is_window1_ff <= 0;
            is_window2_ff <= 0;
            is_column1_ff <= 0;
            is_column2_ff <= 0;
            is_column3_ff <= 0;
            is_grid_pattern_ff <= 0;
            is_wall_ff <= 0;
        end else begin
            // Floor detection
            is_floor_ff <= (vcount_ff >= floor_threshold);
            
            // Wall detection (area where grid should be drawn)
            is_wall_ff <= (vcount_ff < floor_threshold);
            
            // Carpet detection
            is_carpet_ff <= (vcount_ff >= floor_threshold + 5) && 
                           (vcount_ff <= floor_threshold + 45);
            
            // Window detection
            is_window1_ff <= (hcount_ff > window1_center_x - 32) && 
                            (hcount_ff < window1_center_x + 32) &&
                            (vcount_ff > VER_PIXELS/3) && 
                            (vcount_ff < VER_PIXELS/3 + 96);
            
            is_window2_ff <= (hcount_ff > window2_center_x - 32) && 
                            (hcount_ff < window2_center_x + 32) &&
                            (vcount_ff > VER_PIXELS/3) && 
                            (vcount_ff < VER_PIXELS/3 + 96);
            
            // Column detection
            is_column1_ff <= (hcount_ff > column1_x - 15) && 
                            (hcount_ff < column1_x + 15) &&
                            (vcount_ff < floor_threshold);
            is_column2_ff <= (hcount_ff > column2_x - 15) && 
                            (hcount_ff < column2_x + 15) &&
                            (vcount_ff < floor_threshold);
            is_column3_ff <= (hcount_ff > column3_x - 15) && 
                            (hcount_ff < column3_x + 15) &&
                            (vcount_ff < floor_threshold);
            
            // Grid pattern detection - only on wall areas (not on windows/columns)
            if (is_wall_ff && !is_window1_ff && !is_window2_ff && 
                !is_column1_ff && !is_column2_ff && !is_column3_ff) begin
                is_grid_pattern_ff <= ((((vcount_ff / 16) % 2 == 1 ? (hcount_ff + 16) : hcount_ff) % 32) < 2 ||
                                     (((vcount_ff / 16) % 2 == 1 ? (hcount_ff + 16) : hcount_ff) % 32) > 29 ||
                                     (vcount_ff % 16) < 2);
            end else begin
                is_grid_pattern_ff <= 0;
            end
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 3: RGB calculation (pipelined)
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb_ff <= 0;
        end else begin
            if (vblnk_ff || hblnk_ff) begin
                rgb_ff <= 12'h000;
            end else if (is_floor_ff) begin
                // Floor logic
                if (is_carpet_ff) begin
                    // Carpet pattern
                    if (vcount_ff == floor_threshold + 5 || vcount_ff == floor_threshold + 45 ||
                        (hcount_ff >= 10 && hcount_ff <= 12) ||
                        (hcount_ff >= HOR_PIXELS - 12 && hcount_ff <= HOR_PIXELS - 10)) begin
                        rgb_ff <= 12'hff0; // Yellow border
                    end else begin
                        rgb_ff <= 12'h80a; // Purple carpet
                    end
                end else if ((vcount_ff % 8) < 2) begin
                    rgb_ff <= 12'h420; // Dark floor pattern
                end else begin
                    rgb_ff <= 12'h642; // Base floor
                end
            end else begin
                // Wall logic - grid is drawn first as background
                if (is_grid_pattern_ff) begin
                    rgb_ff <= 12'h444; // Grid pattern
                end 
                // Then windows (on top of grid)
                else if (is_window1_ff || is_window2_ff) begin
                    if (vcount_ff >= VER_PIXELS/3 + 20) begin
                        rgb_ff <= 12'h6cf; // Window blue (lower part)
                    end else begin
                        rgb_ff <= 12'h8df; // Window light blue (upper part)
                    end
                end 
                // Then columns (on top of grid and windows)
                else if (is_column1_ff || is_column2_ff || is_column3_ff) begin
                    // Column pattern
                    if ((hcount_ff % 4) == 1) begin
                        rgb_ff <= 12'h222; // Column dark pattern
                    end else begin
                        rgb_ff <= 12'h444; // Column base
                    end
                end 
                // Base wall color (behind grid)
                else begin
                    rgb_ff <= 12'h666; // Base wall
                end
            end
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 4: Output registration
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vga_bg_out.vcount <= '0;
            vga_bg_out.vsync  <= '0;
            vga_bg_out.vblnk  <= '0;
            vga_bg_out.hcount <= '0;
            vga_bg_out.hsync  <= '0;
            vga_bg_out.hblnk  <= '0;
            vga_bg_out.rgb    <= '0;
        end else begin
            vga_bg_out.vcount <= vcount_in;
            vga_bg_out.vsync  <= vsync_in;
            vga_bg_out.vblnk  <= vblnk_in;
            vga_bg_out.hcount <= hcount_in;
            vga_bg_out.hsync  <= hsync_in;
            vga_bg_out.hblnk  <= hblnk_in;
            vga_bg_out.rgb    <= rgb_ff;
        end
    end

endmodule