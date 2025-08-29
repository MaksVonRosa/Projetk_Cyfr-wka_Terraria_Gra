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
    input  logic [11:0] melee_data,
    input  logic [11:0] archer_data,
    input  logic [11:0] select_data,
    output logic [18:0] rom_addr,
    output logic [18:0] rom_addr_select,
    output logic [1:0]  char_class,
    output logic [3:0]  char_hp,
    output logic [3:0]  class_aggro,
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

    localparam SELECT_X = (HOR_PIXELS - 250)/2;
    localparam SELECT_Y = (VER_PIXELS - 75)/3;
    localparam SELECT_W = 250;
    localparam SELECT_H = 75;

    logic [1:0] selected_class;
    
    // Pipeline registers
    logic [11:0] vga_hcount_ff, vga_vcount_ff;
    logic [11:0] vga_rgb_ff;
    logic game_active_ff;
    logic in_left_ff, in_right_ff, in_center_ff, select_rect_ff;
    logic [11:0] rel_x_ff, rel_y_ff;
    logic [11:0] melee_data_ff, archer_data_ff, select_data_ff;
    logic [11:0] rgb_out_ff;
    
    // Mouse input registration
    logic [11:0] mouse_x_ff, mouse_y_ff;
    logic mouse_clicked_ff;
    
    // ADDED: Registered output for other modules
    logic [1:0] selected_class_reg;
    logic [3:0] char_hp_reg;
    logic [3:0] class_aggro_reg;

    //------------------------------------------------------------------------------
    // STAGE 1: Input registration
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vga_hcount_ff <= 0;
            vga_vcount_ff <= 0;
            vga_rgb_ff <= 0;
            game_active_ff <= 0;
            melee_data_ff <= 0;
            archer_data_ff <= 0;
            select_data_ff <= 0;
            mouse_x_ff <= 0;
            mouse_y_ff <= 0;
            mouse_clicked_ff <= 0;
        end else begin
            vga_hcount_ff <= vga_in.hcount;
            vga_vcount_ff <= vga_in.vcount;
            vga_rgb_ff <= vga_in.rgb;
            game_active_ff <= (game_active == 0);
            melee_data_ff <= melee_data;
            archer_data_ff <= archer_data;
            select_data_ff <= select_data;
            mouse_x_ff <= mouse_x;
            mouse_y_ff <= mouse_y;
            mouse_clicked_ff <= mouse_clicked;
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 2: Region detection
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            in_left_ff <= 0;
            in_right_ff <= 0;
            in_center_ff <= 0;
            select_rect_ff <= 0;
            rel_x_ff <= 0;
            rel_y_ff <= 0;
        end else begin
            in_left_ff <= (vga_hcount_ff >= LEFT_X && vga_hcount_ff < LEFT_X+RECT_W &&
                          vga_vcount_ff >= TOP_Y && vga_vcount_ff < TOP_Y+RECT_H);
            in_right_ff <= (vga_hcount_ff >= RIGHT_X && vga_hcount_ff < RIGHT_X+RECT_W &&
                           vga_vcount_ff >= TOP_Y && vga_vcount_ff < TOP_Y+RECT_H);
            in_center_ff <= (vga_hcount_ff >= CENTER_X && vga_hcount_ff < CENTER_X+RECT_W &&
                            vga_vcount_ff >= CENTER_Y && vga_vcount_ff < CENTER_Y+RECT_H);
            select_rect_ff <= (vga_hcount_ff >= SELECT_X && vga_hcount_ff < SELECT_X+SELECT_W &&
                              vga_vcount_ff >= SELECT_Y && vga_vcount_ff < SELECT_Y+SELECT_H);
            
            if (in_left_ff) begin
                rel_x_ff <= vga_hcount_ff - LEFT_X;
                rel_y_ff <= vga_vcount_ff - TOP_Y;
            end else if (in_right_ff) begin
                rel_x_ff <= vga_hcount_ff - RIGHT_X;
                rel_y_ff <= vga_vcount_ff - TOP_Y;
            end else if (in_center_ff) begin
                rel_x_ff <= vga_hcount_ff - CENTER_X;
                rel_y_ff <= vga_vcount_ff - CENTER_Y;
            end else begin
                rel_x_ff <= 0;
                rel_y_ff <= 0;
            end
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 3: ROM address calculation
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rom_addr <= 0;
            rom_addr_select <= 0;
        end else begin
            rom_addr <= rel_y_ff * RECT_W + rel_x_ff;
            rom_addr_select <= (vga_vcount_ff - SELECT_Y) * SELECT_W +
                              (vga_hcount_ff - SELECT_X);
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 4: Class selection logic
    //------------------------------------------------------------------------------
    logic in_left_click_zone, in_right_click_zone;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            in_left_click_zone <= 0;
            in_right_click_zone <= 0;
        end else begin
            // Pre-calculate click zones
            in_left_click_zone <= (mouse_x_ff >= LEFT_X && mouse_x_ff < LEFT_X+RECT_W &&
                                  mouse_y_ff >= TOP_Y && mouse_y_ff < TOP_Y+RECT_H);
            in_right_click_zone <= (mouse_x_ff >= RIGHT_X && mouse_x_ff < RIGHT_X+RECT_W &&
                                   mouse_y_ff >= TOP_Y && mouse_y_ff < TOP_Y+RECT_H);
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            selected_class <= 0;
        end else if (game_active_ff && mouse_clicked_ff) begin
            if (in_left_click_zone)
                selected_class <= 1;
            else if (in_right_click_zone)
                selected_class <= 2;
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 5: Registered outputs for other modules (CRITICAL FIX)
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            selected_class_reg <= 0;
            char_hp_reg <= 0;
            class_aggro_reg <= 0;
        end else begin
            selected_class_reg <= selected_class;
            
            // Pre-calculate outputs to avoid complex comb logic in other modules
            case (selected_class)
                1: begin
                    char_hp_reg <= 4'd10;
                    class_aggro_reg <= 4'd3;
                end
                2: begin
                    char_hp_reg <= 4'd5;
                    class_aggro_reg <= 4'd1;
                end
                default: begin
                    char_hp_reg <= 4'd0;
                    class_aggro_reg <= 4'd0;
                end
            endcase
        end
    end

    //------------------------------------------------------------------------------
    // STAGE 6: RGB output logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb_out_ff <= 0;
        end else begin
            rgb_out_ff <= vga_rgb_ff;
            
            if (game_active_ff) begin
                if (in_left_ff && melee_data_ff != TRANSPARENT_COLOR)
                    rgb_out_ff <= melee_data_ff;
                else if (in_right_ff && archer_data_ff != TRANSPARENT_COLOR)
                    rgb_out_ff <= archer_data_ff;
                else if (select_rect_ff && selected_class == 0)
                    rgb_out_ff <= select_data_ff;
                else if (in_center_ff) begin
                    if (selected_class == 1 && melee_data_ff != TRANSPARENT_COLOR)
                        rgb_out_ff <= melee_data_ff;
                    else if (selected_class == 2 && archer_data_ff != TRANSPARENT_COLOR)
                        rgb_out_ff <= archer_data_ff;
                    else if (rel_x_ff < 2 || rel_x_ff >= RECT_W-2 || 
                             rel_y_ff < 2 || rel_y_ff >= RECT_H-2)
                        rgb_out_ff <= 12'hFFF;
                end
            end
        end
    end

    //------------------------------------------------------------------------------
    // OUTPUT: Registered outputs
    //------------------------------------------------------------------------------
    assign char_class = selected_class_reg;
    assign char_hp    = char_hp_reg;
    assign class_aggro = class_aggro_reg;

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
            vga_out.rgb    <= rgb_out_ff;
        end
    end
endmodule