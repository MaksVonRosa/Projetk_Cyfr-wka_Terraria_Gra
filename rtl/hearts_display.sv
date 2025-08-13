module hearts_display #(
    parameter MAX_HP  = 10,
    parameter HEART_W = 10,
    parameter HEART_H = 9,
    parameter GAP     = 4,
    parameter PADDING = 4
)(
    input  logic clk,
    input  logic rst,
    input  logic [3:0] char_hp,
    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    logic [11:0] heart_rom [0:HEART_W*HEART_H-1];
    initial $readmemh("../GameSprites/Heart.dat", heart_rom);

    logic [11:0] rgb_nxt;
    logic [11:0] rel_x;
    logic [11:0] rel_y;
    logic [10:0] rom_addr;
    logic [11:0] pixel_color;

    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (!vga_in.vblnk && !vga_in.hblnk) begin
            if (vga_in.vcount >= PADDING && vga_in.vcount < PADDING + HEART_H) begin
                for (int i = 0; i < MAX_HP; i++) begin
                    if (i < char_hp) begin
                        int hx_start = PADDING + i * (HEART_W + GAP);
                        int hx_end   = hx_start + HEART_W;

                        if (vga_in.hcount >= hx_start && vga_in.hcount < hx_end) begin
                            rel_x = vga_in.hcount - hx_start;
                            rel_y = vga_in.vcount - PADDING;
                            rom_addr = rel_y * HEART_W + rel_x;
                            pixel_color = heart_rom[rom_addr];

                            if (pixel_color != 12'h00F) rgb_nxt = pixel_color;
                        end
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
