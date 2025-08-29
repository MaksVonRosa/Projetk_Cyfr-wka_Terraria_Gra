//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   weapon_draw
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:  Module for drawing weapons, melee weapon collides with boss 
 */
//////////////////////////////////////////////////////////////////////////////
module weapon_draw (
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0] pos_x_melee_offset,
    input  logic [11:0] pos_y_melee_offset,
    input  logic        flip_hor_melee,
    input  logic        mouse_clicked,
    input  logic [11:0] anim_x_offset,
    input  logic [1:0]  game_active,
    input  logic [1:0]  char_class,
    input  logic [11:0] pos_x_archer_offset,
    input  logic [11:0] pos_y_archer_offset,
    input  logic        flip_hor_archer,
    input  logic        boss_alive,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic        alive,
    input  logic [11:0] melee_data,
    input  logic [11:0] archer_data,
    output logic [15:0] rom_addr, 
    output logic        melee_hit,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam MELEE_IMG_WIDTH  = 54;
    localparam MELEE_IMG_HEIGHT = 28;
    localparam MELEE_WPN_HGT   = 26;
    localparam MELEE_WPN_LNG   = MELEE_IMG_WIDTH/2; 

    localparam ARCHER_IMG_WIDTH  = 40;
    localparam ARCHER_IMG_HEIGHT = 31;
    localparam ARCHER_WPN_HGT   = 26;
    localparam ARCHER_WPN_LNG   = ARCHER_IMG_WIDTH/2; 

    // Pipeline registers
    logic [11:0] rgb_nxt;
    logic [11:0] vga_hcount_ff, vga_vcount_ff;
    logic [11:0] vga_rgb_ff;
    logic vga_vblnk_ff, vga_hblnk_ff;
    logic mouse_clicked_ff;
    logic [1:0] game_active_ff;
    logic [1:0] char_class_ff;
    logic alive_ff;
    logic boss_alive_ff;
    logic [11:0] boss_x_ff, boss_y_ff;
    logic [11:0] pos_x_melee_offset_ff, pos_y_melee_offset_ff;
    logic [11:0] pos_x_archer_offset_ff, pos_y_archer_offset_ff;
    logic flip_hor_melee_ff, flip_hor_archer_ff;
    logic [11:0] anim_x_offset_ff;
    logic [11:0] melee_data_ff, archer_data_ff;

    // Detection signals
    logic melee_active, archer_active;
    logic [11:0] rel_x_ff, rel_y_ff;
    logic [15:0] rom_addr_ff;
    logic melee_hit_ff;

    //------------------------------------------------------------------------------
    // STAGE 1: Input registration
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vga_hcount_ff <= 0;
            vga_vcount_ff <= 0;
            vga_rgb_ff <= 0;
            vga_vblnk_ff <= 0;
            vga_hblnk_ff <= 0;
            mouse_clicked_ff <= 0;
            game_active_ff <= 0;
            char_class_ff <= 0;
            alive_ff <= 0;
            boss_alive_ff <= 0;
            boss_x_ff <= 0;
            boss_y_ff <= 0;
            pos_x_melee_offset_ff <= 0;
            pos_y_melee_offset_ff <= 0;
            pos_x_archer_offset_ff <= 0;
            pos_y_archer_offset_ff <= 0;
            flip_hor_melee_ff <= 0;
            flip_hor_archer_ff <= 0;
            anim_x_offset_ff <= 0;
            melee_data_ff <= 0;
            archer_data_ff <= 0;
        end else begin
            vga_hcount_ff <= vga_in.hcount;
            vga_vcount_ff <= vga_in.vcount;
            vga_rgb_ff <= vga_in.rgb;
            vga_vblnk_ff <= vga_in.vblnk;
            vga_hblnk_ff <= vga_in.hblnk;
            mouse_clicked_ff <= mouse_clicked;
            game_active_ff <= game_active;
            char_class_ff <= char_class;
            alive_ff <= alive;
            boss_alive_ff <= boss_alive;
            boss_x_ff <= boss_x;
            boss_y_ff <= boss_y;
            pos_x_melee_offset_ff <= pos_x_melee_offset;
            pos_y_melee_offset_ff <= pos_y_melee_offset;
            pos_x_archer_offset_ff <= pos_x_archer_offset;
            pos_y_archer_offset_ff <= pos_y_archer_offset;
            flip_hor_melee_ff <= flip_hor_melee;
            flip_hor_archer_ff <= flip_hor_archer;
            anim_x_offset_ff <= anim_x_offset;
            melee_data_ff <= melee_data;
            archer_data_ff <= archer_data;
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 2: Weapon detection logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            melee_active <= 0;
            archer_active <= 0;
            rel_x_ff <= 0;
            rel_y_ff <= 0;
            rom_addr_ff <= 0;
            melee_hit_ff <= 0;
        end else begin
            melee_active <= 0;
            archer_active <= 0;
            rel_x_ff <= 0;
            rel_y_ff <= 0;
            rom_addr_ff <= 0;
            melee_hit_ff <= 0;

            if(mouse_clicked_ff && game_active_ff && alive_ff && !vga_vblnk_ff && !vga_hblnk_ff) begin
                case (char_class_ff)
                    2'b01: begin  // Melee
                        logic [11:0] melee_x_pos;
                        melee_x_pos = pos_x_melee_offset_ff + (flip_hor_melee_ff ? -anim_x_offset_ff : anim_x_offset_ff);
                        
                        if (vga_hcount_ff >= melee_x_pos - MELEE_WPN_LNG &&
                            vga_hcount_ff <  melee_x_pos + MELEE_WPN_LNG &&
                            vga_vcount_ff >= pos_y_melee_offset_ff - MELEE_WPN_HGT &&
                            vga_vcount_ff <  pos_y_melee_offset_ff + MELEE_WPN_HGT) begin

                            rel_y_ff <= vga_vcount_ff - (pos_y_melee_offset_ff - MELEE_WPN_HGT);
                            rel_x_ff <= vga_hcount_ff - (melee_x_pos - MELEE_WPN_LNG);

                            if (flip_hor_melee_ff) 
                                rel_x_ff <= (MELEE_IMG_WIDTH-1) - rel_x_ff;
                            
                            if (rel_x_ff < MELEE_IMG_WIDTH && rel_y_ff < MELEE_IMG_HEIGHT) begin
                                melee_active <= 1;
                                rom_addr_ff <= rel_y_ff * MELEE_IMG_WIDTH + rel_x_ff;
                            end
                            
                            // Collision detection
                            if (boss_alive_ff &&
                                vga_hcount_ff >= boss_x_ff - BOSS_LNG && 
                                vga_hcount_ff <= boss_x_ff + BOSS_LNG &&
                                vga_vcount_ff >= boss_y_ff - BOSS_HGT && 
                                vga_vcount_ff <= boss_y_ff + BOSS_HGT) begin
                                melee_hit_ff <= 1;
                            end
                        end
                    end

                    2'b10: begin // Archer
                        if (vga_hcount_ff >= pos_x_archer_offset_ff - ARCHER_WPN_LNG &&
                            vga_hcount_ff <  pos_x_archer_offset_ff + ARCHER_WPN_LNG &&
                            vga_vcount_ff >= pos_y_archer_offset_ff - ARCHER_WPN_HGT &&
                            vga_vcount_ff <  pos_y_archer_offset_ff + ARCHER_WPN_HGT) begin

                            rel_y_ff <= vga_vcount_ff - (pos_y_archer_offset_ff - ARCHER_WPN_HGT);
                            rel_x_ff <= vga_hcount_ff - (pos_x_archer_offset_ff - ARCHER_WPN_LNG);

                            if (flip_hor_archer_ff) 
                                rel_x_ff <= (ARCHER_IMG_WIDTH-1) - rel_x_ff;
                            
                            if (rel_x_ff < ARCHER_IMG_WIDTH && rel_y_ff < ARCHER_IMG_HEIGHT) begin
                                archer_active <= 1;
                                rom_addr_ff <= rel_y_ff * ARCHER_IMG_WIDTH + rel_x_ff;
                            end
                        end
                    end
                endcase
            end
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 3: RGB output logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb_nxt <= 0;
            melee_hit <= 0;
            rom_addr <= 0;
        end else begin
            rgb_nxt <= vga_rgb_ff;
            melee_hit <= melee_hit_ff;
            rom_addr <= rom_addr_ff;
            
            if (melee_active && melee_data_ff != 12'h02F) begin
                rgb_nxt <= melee_data_ff;
            end else if (archer_active && archer_data_ff != 12'hF00) begin
                rgb_nxt <= archer_data_ff;
            end
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 4: VGA output
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vga_out.vcount <= 0;
            vga_out.vsync  <= 0;
            vga_out.vblnk  <= 0;
            vga_out.hcount <= 0;
            vga_out.hsync  <= 0;
            vga_out.hblnk  <= 0;
            vga_out.rgb    <= 0;
        end else begin
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end

endmodule