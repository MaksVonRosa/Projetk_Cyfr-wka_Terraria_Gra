module game_screen (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] game_active,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    localparam RECT_X = HOR_PIXELS/4;
    localparam RECT_Y = VER_PIXELS/3;
    localparam RECT_W = HOR_PIXELS/2;
    localparam RECT_H = VER_PIXELS/3;

    localparam BLACK = 12'h000;
    localparam YELLOW = 12'hFF0;

    logic [11:0] rgb_nxt;
    logic in_rect;

    always_comb begin
        rgb_nxt = vga_in.rgb;
        in_rect = (vga_in.hcount >= RECT_X && vga_in.hcount < RECT_X+RECT_W &&
                   vga_in.vcount >= RECT_Y && vga_in.vcount < RECT_Y+RECT_H);

        if ((game_active == 0 || game_active == 2) && in_rect)
            rgb_nxt = BLACK;

        if (game_active == 0 && in_rect) begin
            // S
            if ((vga_in.hcount>=RECT_X+20 && vga_in.hcount<RECT_X+50 && vga_in.vcount>=RECT_Y+20 && vga_in.vcount<RECT_Y+30) ||
                (vga_in.hcount>=RECT_X+20 && vga_in.hcount<RECT_X+30 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+60) ||
                (vga_in.hcount>=RECT_X+20 && vga_in.hcount<RECT_X+50 && vga_in.vcount>=RECT_Y+60 && vga_in.vcount<RECT_Y+70) ||
                (vga_in.hcount>=RECT_X+40 && vga_in.hcount<RECT_X+50 && vga_in.vcount>=RECT_Y+70 && vga_in.vcount<RECT_Y+100))
                rgb_nxt = YELLOW;
            // T
            if ((vga_in.hcount>=RECT_X+60 && vga_in.hcount<RECT_X+100 && vga_in.vcount>=RECT_Y+20 && vga_in.vcount<RECT_Y+30) ||
                (vga_in.hcount>=RECT_X+80 && vga_in.hcount<RECT_X+90 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100))
                rgb_nxt = YELLOW;
            // A
            if ((vga_in.hcount>=RECT_X+110 && vga_in.hcount<RECT_X+120 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100) ||
                (vga_in.hcount>=RECT_X+140 && vga_in.hcount<RECT_X+150 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100) ||
                (vga_in.hcount>=RECT_X+120 && vga_in.hcount<RECT_X+140 && vga_in.vcount>=RECT_Y+50 && vga_in.vcount<RECT_Y+60))
                rgb_nxt = YELLOW;
            // R
            if ((vga_in.hcount>=RECT_X+160 && vga_in.hcount<RECT_X+170 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100) ||
                (vga_in.hcount>=RECT_X+170 && vga_in.hcount<RECT_X+200 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+40) ||
                (vga_in.hcount>=RECT_X+200 && vga_in.hcount<RECT_X+210 && vga_in.vcount>=RECT_Y+40 && vga_in.vcount<RECT_Y+60) ||
                (vga_in.hcount>=RECT_X+170 && vga_in.hcount<RECT_X+200 && vga_in.vcount>=RECT_Y+60 && vga_in.vcount<RECT_Y+70) ||
                (vga_in.hcount>=RECT_X+200 && vga_in.hcount<RECT_X+210 && vga_in.vcount>=RECT_Y+70 && vga_in.vcount<RECT_Y+100))
                rgb_nxt = YELLOW;
        end

        if (game_active == 2 && in_rect) begin
            // E
            if ((vga_in.hcount>=RECT_X+30 && vga_in.hcount<RECT_X+40 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100) ||
                (vga_in.hcount>=RECT_X+30 && vga_in.hcount<RECT_X+70 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+40) ||
                (vga_in.hcount>=RECT_X+30 && vga_in.hcount<RECT_X+60 && vga_in.vcount>=RECT_Y+60 && vga_in.vcount<RECT_Y+70) ||
                (vga_in.hcount>=RECT_X+30 && vga_in.hcount<RECT_X+70 && vga_in.vcount>=RECT_Y+90 && vga_in.vcount<RECT_Y+100))
                rgb_nxt = YELLOW;
            // N
            if ((vga_in.hcount>=RECT_X+80 && vga_in.hcount<RECT_X+90 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100) ||
                (vga_in.hcount>=RECT_X+80 && vga_in.hcount<RECT_X+140 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+40) ||
                (vga_in.hcount>=RECT_X+130 && vga_in.hcount<RECT_X+140 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100))
                rgb_nxt = YELLOW;
                // D
            if ((vga_in.hcount>=RECT_X+150 && vga_in.hcount<RECT_X+160 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+100) ||
                (vga_in.hcount>=RECT_X+150 && vga_in.hcount<RECT_X+190 && vga_in.vcount>=RECT_Y+30 && vga_in.vcount<RECT_Y+40) ||
                (vga_in.hcount>=RECT_X+190 && vga_in.hcount<RECT_X+200 && vga_in.vcount>=RECT_Y+40 && vga_in.vcount<RECT_Y+90) ||
                (vga_in.hcount>=RECT_X+150 && vga_in.hcount<RECT_X+190 && vga_in.vcount>=RECT_Y+90 && vga_in.vcount<RECT_Y+100))
                rgb_nxt = YELLOW;
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
