//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   boss_render
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Boss rendering module with health bar display - OPTYMALIZOWANA
 */
//////////////////////////////////////////////////////////////////////////////
module boss_render (
    input  logic clk,
    input  logic [1:0] game_active,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [6:0] boss_hp,
    input  logic [11:0] boss_data,
    output logic [15:0] rom_addr, 
    output logic boss_alive,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam BOSS_HGT    = 95;
    localparam BOSS_LNG    = 106;
    localparam IMG_WIDTH   = 212;
    localparam IMG_HEIGHT  = 191;

    logic [10:0] vga_hcount, vga_vcount;
    logic vga_vblnk, vga_hblnk;
    logic [11:0] vga_rgb_in;
    logic [1:0] game_active_reg;
    logic [11:0] boss_x_reg, boss_y_reg;
    logic [6:0] boss_hp_reg;

    always_ff @(posedge clk) begin
        vga_hcount <= vga_in.hcount;
        vga_vcount <= vga_in.vcount;
        vga_vblnk <= vga_in.vblnk;
        vga_hblnk <= vga_in.hblnk;
        vga_rgb_in <= vga_in.rgb;
        game_active_reg <= game_active;
        boss_x_reg <= boss_x;
        boss_y_reg <= boss_y;
        boss_hp_reg <= boss_hp;
    end

    logic boss_active;
    logic [11:0] x_min, x_max, y_min, y_max;
    logic in_boss_area;

    always_ff @(posedge clk) begin
        boss_active <= (game_active_reg == 1) && (boss_hp_reg > 0);
        
        x_min <= boss_x_reg - BOSS_LNG;
        x_max <= boss_x_reg + BOSS_LNG;
        y_min <= boss_y_reg - BOSS_HGT;
        y_max <= boss_y_reg + BOSS_HGT;
        
        in_boss_area <= boss_active && !vga_vblnk && !vga_hblnk &&
                       (vga_hcount >= x_min) && (vga_hcount < x_max) &&
                       (vga_vcount >= y_min) && (vga_vcount < y_max);
    end

    logic [8:0] rel_x, rel_y;
    logic calculate_coords;

    always_ff @(posedge clk) begin
        calculate_coords <= in_boss_area;
        
        if (in_boss_area) begin
            rel_y <= vga_vcount - y_min;
            rel_x <= vga_hcount - x_min;
        end
    end

    logic [15:0] rom_addr_calc;
    logic valid_rom_addr;

    always_ff @(posedge clk) begin
        rom_addr_calc <= rel_y * IMG_WIDTH + rel_x;
        valid_rom_addr <= calculate_coords && (rel_x < IMG_WIDTH) && (rel_y < IMG_HEIGHT);
    end

    logic [11:0] rgb_nxt;
    logic transparent_pixel;

    always_ff @(posedge clk) begin
        transparent_pixel <= (boss_data == 12'hF00);
        
        if (valid_rom_addr && !transparent_pixel) begin
            rgb_nxt <= boss_data;
        end else begin
            rgb_nxt <= vga_rgb_in;
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
        boss_alive     <= boss_active;
        rom_addr       <= rom_addr_calc;
    end
endmodule