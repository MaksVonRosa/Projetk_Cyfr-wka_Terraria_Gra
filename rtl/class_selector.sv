module class_selector (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic [11:0] mouse_x,
    input  logic [11:0] mouse_y,
    input  logic        mouse_clicked,
    output logic [1:0]  char_class,
    output logic [3:0]  char_hp,
    output logic [1:0]  wpn_type,
    output logic projectile_active,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam RECT_W = 39;
    localparam RECT_H = 53;
    localparam LEFT_X = HOR_PIXELS/3;
    localparam RIGHT_X = HOR_PIXELS*2/3;
    localparam CENTER_X = (HOR_PIXELS - RECT_W)/2;
    localparam TOP_Y = VER_PIXELS*2/3;
    localparam CENTER_Y = TOP_Y + RECT_H/2;
    localparam [11:0] TRANSPARENT_COLOR = 12'hF00;

    logic [11:0] melee_rom [0:RECT_W*RECT_H-1];
    logic [11:0] archer_rom[0:RECT_W*RECT_H-1];
    logic [1:0]  selected_class;
    logic in_left, in_right, in_center;
    logic [11:0] rel_x, rel_y;
    logic [18:0] rom_addr;
    logic [11:0] rgb_out;

    initial begin
        $readmemh("../GameSprites/Melee.dat", melee_rom);
        $readmemh("../GameSprites/Archer.dat", archer_rom);
    end

    assign char_class = selected_class;
    assign char_hp    = (selected_class == 1) ? 4'd10 :   // melee
                        (selected_class == 2) ? 4'd8  :   // archer
                                                4'd0;    // none
    assign wpn_type   = selected_class; // 1 = sword, 2 = gun, 0 = none

    always_comb begin
        rgb_out = vga_in.rgb;
        in_left = (vga_in.hcount >= LEFT_X && vga_in.hcount < LEFT_X+RECT_W &&
                   vga_in.vcount >= TOP_Y && vga_in.vcount < TOP_Y+RECT_H);
        in_right = (vga_in.hcount >= RIGHT_X && vga_in.hcount < RIGHT_X+RECT_W &&
                    vga_in.vcount >= TOP_Y && vga_in.vcount < TOP_Y+RECT_H);
        in_center = (vga_in.hcount >= CENTER_X && vga_in.hcount < CENTER_X+RECT_W &&
                     vga_in.vcount >= CENTER_Y && vga_in.vcount < CENTER_Y+RECT_H);

        rel_x = in_left   ? (vga_in.hcount - LEFT_X)   :
                in_right  ? (vga_in.hcount - RIGHT_X)  :
                in_center ? (vga_in.hcount - CENTER_X) : 0;
        rel_y = in_left   ? (vga_in.vcount - TOP_Y)    :
                in_right  ? (vga_in.vcount - TOP_Y)    :
                in_center ? (vga_in.vcount - CENTER_Y) : 0;
        rom_addr = rel_y * RECT_W + rel_x;

        if (game_active == 0) begin
            if (in_left && melee_rom[rom_addr] != TRANSPARENT_COLOR)
                rgb_out = melee_rom[rom_addr];
            if (in_right && archer_rom[rom_addr] != TRANSPARENT_COLOR)
                rgb_out = archer_rom[rom_addr];
            if (in_center) begin
                if (selected_class == 1 && melee_rom[rom_addr] != TRANSPARENT_COLOR)
                    rgb_out = melee_rom[rom_addr];
                else if (selected_class == 2 && archer_rom[rom_addr] != TRANSPARENT_COLOR)
                    rgb_out = archer_rom[rom_addr];
                else if (rel_x < 2 || rel_x >= RECT_W-2 || rel_y < 2 || rel_y >= RECT_H-2)
                    rgb_out = 12'hFFF;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            selected_class <= 0; // none
            projectile_active <= 0;
        end else if (game_active == 0) begin
            if (mouse_clicked) begin
                if (mouse_x >= LEFT_X && mouse_x < LEFT_X+RECT_W &&
                    mouse_y >= TOP_Y && mouse_y < TOP_Y+RECT_H) begin
                    selected_class <= 1; // melee
                end else if (mouse_x >= RIGHT_X && mouse_x < RIGHT_X+RECT_W &&
                             mouse_y >= TOP_Y && mouse_y < TOP_Y+RECT_H) begin
                    selected_class <= 2; // archer
                    projectile_active <= 1;
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
        vga_out.rgb    <= rgb_out;
    end
endmodule
