module char_draw (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] pos_x,
    input  logic [11:0] pos_y,
    output logic [11:0] char_hgt,
    output logic [11:0] char_lng,

    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam CHAR_HGT = 32;
    localparam CHAR_LNG = 25;
    localparam CHAR_COL = 12'h1_5_a;

    logic [11:0] draw_x, draw_y, rgb_nxt;

    always_ff @(posedge clk) begin
        if (rst) begin
            draw_x <= HOR_PIXELS / 2;
            draw_y <= VER_PIXELS - 20 - CHAR_HGT;
        end else begin
            draw_x <= pos_x;
            draw_y <= pos_y;
        end
    end

    always_ff @(posedge clk) begin
        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt <= 12'h000;
        end else if (
            vga_in.hcount >= draw_x - CHAR_LNG &&
            vga_in.hcount <= draw_x + CHAR_LNG &&
            vga_in.vcount >= draw_y - CHAR_HGT &&
            vga_in.vcount <= draw_y + CHAR_HGT
        ) begin
            rgb_nxt <= CHAR_COL;
        end else begin
            rgb_nxt <= vga_in.rgb;
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
        char_hgt <= CHAR_HGT;
        char_lng <= CHAR_LNG;
    end

endmodule
