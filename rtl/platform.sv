module platform (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    input  logic [11:0] char_hgt,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic on_ground
);
    import vga_pkg::*;

    localparam PLAT_COUNT = 5;
    localparam PLAT_THICK = 15;
    localparam PLAT_COLOR = 12'hF60;
    
    logic [11:0] plat_x[PLAT_COUNT] = '{200, 400, 150, 500, 300};
    logic [11:0] plat_y[PLAT_COUNT] = '{400, 350, 250, 200, 150};
    logic [11:0] plat_w[PLAT_COUNT] = '{100, 80, 120, 90, 110};
    
    logic [11:0] rgb_nxt;
    logic [11:0] char_y_prev;

    always_ff @(posedge clk) begin
        char_y_prev <= char_y;
    end

    always_comb begin
        on_ground = 0;
        for (int i = 0; i < PLAT_COUNT; i++) begin
            if ((char_x + char_hgt/2 > plat_x[i]) && 
                (char_x - char_hgt/2 < plat_x[i] + plat_w[i]) &&
                (char_y + char_hgt >= plat_y[i] - 2) && 
                (char_y + char_hgt <= plat_y[i] + PLAT_THICK) &&
                (char_y_prev + char_hgt <= plat_y[i])) begin
                on_ground = 1;
            end
        end
        
        rgb_nxt = vga_in.rgb;
        for (int i = 0; i < PLAT_COUNT; i++) begin
            if (!vga_in.vblnk && !vga_in.hblnk &&
                vga_in.hcount >= plat_x[i] && 
                vga_in.hcount < plat_x[i] + plat_w[i] &&
                vga_in.vcount >= plat_y[i] && 
                vga_in.vcount < plat_y[i] + PLAT_THICK) begin
                rgb_nxt = PLAT_COLOR;
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