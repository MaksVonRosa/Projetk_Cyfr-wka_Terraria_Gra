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
    input logic [3:0]  player_2_hp,
    output logic [3:0] current_health,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    logic [11:0] heart_rom [0:HEART_W*HEART_H-1];
    initial $readmemh("../../GameSprites/Heart.dat", heart_rom);

    logic [7:0] damage_cooldown;

    logic [11:0] rgb_nxt;
    logic [11:0] rel_x;
    logic [11:0] rel_y;
    logic [10:0] rom_addr;
    logic [11:0] pixel_color;

    localparam PLAYER1_HEARTS_Y = PADDING;
    localparam PLAYER2_HEARTS_Y = PADDING + HEART_H + GAP;


    always_ff @(posedge clk) begin
        if (rst || game_start || player2_game_start) begin
            current_health <= char_hp;
            damage_cooldown <= 0;
        end else if (frame_tick && game_active == 1) begin
            if (damage_cooldown > 0)
                damage_cooldown <= damage_cooldown - 1;
            if (damage_cooldown == 0 &&
            char_x + char_lng > boss_x &&
            char_x < boss_x + boss_lng &&
            char_y + char_hgt > boss_y &&
            char_y < boss_y + boss_hgt) begin
            if (current_health > 0) begin
                current_health <= current_health - 1;
                damage_cooldown <= COOLDOWN_TICKS;
            end
            else begin
                current_health <= 0;
            end
        end
        end
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;
        if (game_active == 1 && !vga_in.vblnk && !vga_in.hblnk) begin
            
            if (vga_in.vcount >= PLAYER1_HEARTS_Y && vga_in.vcount < PLAYER1_HEARTS_Y + HEART_H) begin
                for (int i = 0; i < MAX_HP; i++) begin
                    automatic int hx_start = PADDING + i * (HEART_W + GAP);
                    automatic int hx_end   = hx_start + HEART_W;
                    if (vga_in.hcount >= hx_start && vga_in.hcount < hx_end) begin
                        rel_x = vga_in.hcount - hx_start;
                        rel_y = vga_in.vcount - PLAYER1_HEARTS_Y;
                        rom_addr = rel_y * HEART_W + rel_x;
                        pixel_color = heart_rom[rom_addr];
                        
                        if (i < current_health && pixel_color != 12'h00F) 
                            rgb_nxt = pixel_color;
                    end
                end
            end
            
            if (vga_in.vcount >= PLAYER2_HEARTS_Y && vga_in.vcount < PLAYER2_HEARTS_Y + HEART_H) begin
                for (int i = 0; i < MAX_HP; i++) begin
                    automatic int hx_start = PADDING + i * (HEART_W + GAP);
                    automatic int hx_end   = hx_start + HEART_W;
                    if (vga_in.hcount >= hx_start && vga_in.hcount < hx_end) begin
                        rel_x = vga_in.hcount - hx_start;
                        rel_y = vga_in.vcount - PLAYER2_HEARTS_Y;
                        rom_addr = rel_y * HEART_W + rel_x;
                        pixel_color = heart_rom[rom_addr];
                        
                        if (i < player_2_hp && pixel_color != 12'h00F) 
                            rgb_nxt = pixel_color;
                    end
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
    end
endmodule