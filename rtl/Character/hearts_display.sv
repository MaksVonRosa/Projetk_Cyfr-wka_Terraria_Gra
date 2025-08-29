//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   hearts_display
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Health points display module with damage cooldown
 */
//////////////////////////////////////////////////////////////////////////////
module hearts_display #(
    parameter MAX_HP  = 10,
    parameter HEART_W = 10,
    parameter HEART_H = 9,
    parameter GAP     = 4,
    parameter PADDING = 4,
    parameter COOLDOWN_TICKS = 60
)(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] char_hp,
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [11:0] char_hgt,
    input  logic [11:0] char_lng,
    input  logic [11:0] boss_hgt,
    input  logic [11:0] boss_lng,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic player2_game_start,
    input  logic frame_tick,
    input  logic [3:0] player_2_hp,
    input  logic [11:0] heart_data,  // Dodane wejście dla danych z ROM
    output logic [10:0] rom_addr,    // Dodane wyjście dla adresu ROM
    output logic [3:0] current_health,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    logic [11:0] rgb_nxt, rel_x, rel_y;
    logic [7:0] damage_cooldown;

    localparam PLAYER1_HEARTS_Y = PADDING;
    localparam PLAYER2_HEARTS_Y = PADDING + HEART_H + GAP;

    always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            current_health <= char_hp;
            damage_cooldown <= 0;
        end else if (frame_tick && game_active==1) begin
            if(damage_cooldown>0) damage_cooldown <= damage_cooldown-1;
            if(damage_cooldown==0 &&
               char_x+char_lng>boss_x && char_x<boss_x+boss_lng &&
               char_y+char_hgt>boss_y && char_y<boss_y+boss_hgt) begin
                if(current_health>0) begin
                    current_health <= current_health-1;
                    damage_cooldown <= COOLDOWN_TICKS;
                end else current_health <= 0;
            end
        end
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;
        rom_addr = 0;  // Domyślna wartość adresu
        
        if(game_active==1 && !vga_in.vblnk && !vga_in.hblnk) begin
            // Player 1 hearts
            if(vga_in.vcount >= PLAYER1_HEARTS_Y && vga_in.vcount < PLAYER1_HEARTS_Y+HEART_H) begin
                for(int i=0;i<MAX_HP;i++) begin
                    int hx_start = PADDING + i*(HEART_W+GAP);
                    int hx_end   = hx_start+HEART_W;
                    if(vga_in.hcount>=hx_start && vga_in.hcount<hx_end) begin
                        rel_x = vga_in.hcount - hx_start;
                        rel_y = vga_in.vcount - PLAYER1_HEARTS_Y;
                        rom_addr = rel_y*HEART_W + rel_x;
                        if(i<current_health && heart_data!=12'h00F) rgb_nxt = heart_data;
                    end
                end
            end
            // Player 2 hearts
            if(vga_in.vcount >= PLAYER2_HEARTS_Y && vga_in.vcount < PLAYER2_HEARTS_Y+HEART_H) begin
                for(int i=0;i<MAX_HP;i++) begin
                    int hx_start = PADDING + i*(HEART_W+GAP);
                    int hx_end   = hx_start+HEART_W;
                    if(vga_in.hcount>=hx_start && vga_in.hcount<hx_end) begin
                        rel_x = vga_in.hcount - hx_start;
                        rel_y = vga_in.vcount - PLAYER2_HEARTS_Y;
                        rom_addr = rel_y*HEART_W + rel_x;
                        if(i<player_2_hp && heart_data!=12'h00F) rgb_nxt = heart_data;
                    end
                end
            end
        end
        vga_out.rgb = rgb_nxt;
    end

    always_ff @(posedge clk) begin
        vga_out.vcount <= vga_in.vcount;
        vga_out.vsync  <= vga_in.vsync;
        vga_out.vblnk  <= vga_in.vblnk;
        vga_out.hcount <= vga_in.hcount;
        vga_out.hsync  <= vga_in.hsync;
        vga_out.hblnk  <= vga_in.hblnk;
    end
endmodule