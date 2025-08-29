//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   game_screen
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-29
 Description:  Game screen module with start/restart button rendering
*/
//////////////////////////////////////////////////////////////////////////////
module game_screen (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    input  logic [1:0] char_class,
    input  logic [1:0] player_2_class,
    input  logic       player_2_data_valid,
    input  logic [11:0] mouse_x,
    input  logic [11:0] mouse_y,
    input  logic        mouse_clicked,
    input  logic [11:0] start_data,
    input  logic [11:0] back_data,
    output logic [13:0] rom_addr,
    output logic        game_start,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    localparam RECT_X = (HOR_PIXELS - 125)/2;
    localparam RECT_Y = (VER_PIXELS - 75)/3;
    localparam RECT_W = 125;
    localparam RECT_H = 75;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    logic [11:0] rgb_nxt;
    logic [11:0] pixel_color;
    
    // Pipeline registers
    logic [11:0] vga_hcount_ff, vga_vcount_ff;
    logic [11:0] vga_rgb_ff;
    logic [1:0] game_active_ff;
    logic in_rect_ff;
    logic [11:0] rel_x_ff, rel_y_ff;
    logic [11:0] start_data_ff, back_data_ff;
    
    // Input registration
    logic [11:0] mouse_x_ff, mouse_y_ff;
    logic mouse_clicked_ff;
    logic [1:0] char_class_ff, player_2_class_ff;
    logic player_2_data_valid_ff;
    logic classes_ok_ff;

    //------------------------------------------------------------------------------
    // Input registration stage
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            vga_hcount_ff <= 0;
            vga_vcount_ff <= 0;
            vga_rgb_ff <= 0;
            game_active_ff <= 0;
            start_data_ff <= 0;
            back_data_ff <= 0;
            mouse_x_ff <= 0;
            mouse_y_ff <= 0;
            mouse_clicked_ff <= 0;
            char_class_ff <= 0;
            player_2_class_ff <= 0;
            player_2_data_valid_ff <= 0;
        end else begin
            vga_hcount_ff <= vga_in.hcount;
            vga_vcount_ff <= vga_in.vcount;
            vga_rgb_ff <= vga_in.rgb;
            game_active_ff <= game_active;
            start_data_ff <= start_data;
            back_data_ff <= back_data;
            mouse_x_ff <= mouse_x;
            mouse_y_ff <= mouse_y;
            mouse_clicked_ff <= mouse_clicked;
            char_class_ff <= char_class;
            player_2_class_ff <= player_2_class;
            player_2_data_valid_ff <= player_2_data_valid;
        end
    end

    //------------------------------------------------------------------------------
    // Class check logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            classes_ok_ff <= 0;
        end else begin
            if (!player_2_data_valid_ff) begin
                classes_ok_ff <= (char_class_ff != 0);
            end else begin
                classes_ok_ff <= (char_class_ff != 0) &&
                                (player_2_class_ff != 0) &&
                                (char_class_ff != player_2_class_ff);
            end
        end
    end

    //------------------------------------------------------------------------------
    // Rectangle detection
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            in_rect_ff <= 0;
            rel_x_ff <= 0;
            rel_y_ff <= 0;
        end else begin
            in_rect_ff <= (vga_hcount_ff >= RECT_X && vga_hcount_ff < RECT_X+RECT_W &&
                          vga_vcount_ff >= RECT_Y && vga_vcount_ff < RECT_Y+RECT_H);
            
            if (in_rect_ff) begin
                rel_x_ff <= vga_hcount_ff - RECT_X;
                rel_y_ff <= vga_vcount_ff - RECT_Y;
            end else begin
                rel_x_ff <= 0;
                rel_y_ff <= 0;
            end
        end
    end

    //------------------------------------------------------------------------------
    // ROM address calculation
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rom_addr <= 0;
        end else begin
            rom_addr <= rel_y_ff * 125 + rel_x_ff;
        end
    end

    //------------------------------------------------------------------------------
    // RGB output logic
    //------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst) begin
            rgb_nxt <= 0;
            pixel_color <= 0;
        end else begin
            rgb_nxt <= vga_rgb_ff;
            pixel_color <= 0;
            
            if (in_rect_ff) begin
                if (game_active_ff == 0)
                    pixel_color <= start_data_ff;
                else if (game_active_ff == 2)
                    pixel_color <= back_data_ff;

                if (pixel_color != 12'h000)
                    rgb_nxt <= pixel_color;
            end
        end
    end

    //------------------------------------------------------------------------------
    // Game start logic
    //------------------------------------------------------------------------------
    logic mouse_in_rect;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            game_start <= 0;
            mouse_in_rect <= 0;
        end else begin
            game_start <= 0;
            
            mouse_in_rect <= (mouse_x_ff >= RECT_X && mouse_x_ff < RECT_X+RECT_W &&
                             mouse_y_ff >= RECT_Y && mouse_y_ff < RECT_Y+RECT_H);

            if (mouse_clicked_ff && mouse_in_rect && classes_ok_ff) begin
                if (game_active_ff == 0 || game_active_ff == 2) begin
                    game_start <= 1;
                end
            end
        end
    end

    //------------------------------------------------------------------------------
    // VGA output
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