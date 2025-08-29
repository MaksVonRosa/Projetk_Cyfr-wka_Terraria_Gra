//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   class_selector
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  Character class selection module with visual interface
 */
//////////////////////////////////////////////////////////////////////////////
module class_selector (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic [11:0] mouse_x,
    input  logic [11:0] mouse_y,
    input  logic        mouse_clicked,
    output logic [1:0]  char_class,
    output logic [3:0]  char_hp,
    output logic [3:0]  class_aggro,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam RECT_W = 39;
    localparam RECT_H = 53;
    localparam LEFT_X = HOR_PIXELS/3;
    localparam RIGHT_X = HOR_PIXELS*2/3;
    localparam CENTER_X = (HOR_PIXELS - RECT_W)/2;
    localparam TOP_Y = VER_PIXELS*2/3;
    localparam CENTER_Y = TOP_Y + RECT_H/2;
    localparam [11:0] TRANSPARENT_COLOR = 12'hF00;


    localparam SELECT_X = (HOR_PIXELS - 250)/2;
    localparam SELECT_Y = (VER_PIXELS - 75)/3;
    localparam SELECT_W = 250;
    localparam SELECT_H = 75;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] melee_rom [0:RECT_W*RECT_H-1];
    logic [11:0] archer_rom[0:RECT_W*RECT_H-1];
    logic [11:0] select_rom[0:SELECT_W*SELECT_H-1];

    logic [1:0]  selected_class;
    logic in_left, in_right, in_center, select_rect;
    logic [11:0] rel_x, rel_y;
    logic [18:0] rom_addr;
    logic [18:0] rom_addr_select;
    logic [11:0] rgb_out;

    initial begin
        $readmemh("../GameSprites/Melee.dat", melee_rom);
        $readmemh("../GameSprites/Archer.dat", archer_rom);
        $readmemh("../GameSprites/SELECT_BUTTON.dat",  select_rom);
    end

    assign char_class = selected_class;
    assign char_hp    = (selected_class == 1) ? 4'd10 :   // melee
                        (selected_class == 2) ? 4'd5  :   // archer
                                                4'd0;    // none
    assign class_aggro = (selected_class == 1) ? 4'd3 :
                         (selected_class == 2) ? 4'd1 :
                                                 4'd0;


    always_ff @(posedge clk) begin
        if (rst) begin
            selected_class <= 0; // none
        end else if (game_active == 0) begin
            if (mouse_clicked) begin
                if (mouse_x >= LEFT_X && mouse_x < LEFT_X+RECT_W &&
                    mouse_y >= TOP_Y && mouse_y < TOP_Y+RECT_H) begin
                    selected_class <= 1; // melee
                end else if (mouse_x >= RIGHT_X && mouse_x < RIGHT_X+RECT_W &&
                             mouse_y >= TOP_Y && mouse_y < TOP_Y+RECT_H) begin
                    selected_class <= 2; // archer
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

    
    always_comb begin
        rgb_out = vga_in.rgb;
        in_left = (vga_in.hcount >= LEFT_X && vga_in.hcount < LEFT_X+RECT_W &&
                   vga_in.vcount >= TOP_Y && vga_in.vcount < TOP_Y+RECT_H);
        in_right = (vga_in.hcount >= RIGHT_X && vga_in.hcount < RIGHT_X+RECT_W &&
                    vga_in.vcount >= TOP_Y && vga_in.vcount < TOP_Y+RECT_H);
        in_center = (vga_in.hcount >= CENTER_X && vga_in.hcount < CENTER_X+RECT_W &&
                     vga_in.vcount >= CENTER_Y && vga_in.vcount < CENTER_Y+RECT_H);
        select_rect = (vga_in.hcount >= SELECT_X && vga_in.hcount < SELECT_X+SELECT_W &&
                     vga_in.vcount >= SELECT_Y && vga_in.vcount < SELECT_Y+SELECT_H);

        rel_x = in_left   ? (vga_in.hcount - LEFT_X)   :
                in_right  ? (vga_in.hcount - RIGHT_X)  :
                in_center ? (vga_in.hcount - CENTER_X) : 0;
        rel_y = in_left   ? (vga_in.vcount - TOP_Y)    :
                in_right  ? (vga_in.vcount - TOP_Y)    :
                in_center ? (vga_in.vcount - CENTER_Y) : 0;
        rom_addr = rel_y * RECT_W + rel_x;
        rom_addr_select = (vga_in.vcount - SELECT_Y) * SELECT_W +
                  (vga_in.hcount - SELECT_X);


        if (game_active == 0) begin
            if (in_left && melee_rom[rom_addr] != TRANSPARENT_COLOR)
                rgb_out = melee_rom[rom_addr];
            if (in_right && archer_rom[rom_addr] != TRANSPARENT_COLOR)
                rgb_out = archer_rom[rom_addr];
            if (select_rect  &&  selected_class == 0)
                rgb_out = select_rom[rom_addr_select];
                
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

endmodule