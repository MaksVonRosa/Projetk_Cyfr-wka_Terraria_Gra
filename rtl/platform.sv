module platform (
    input  logic clk,
    input  logic rst,
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    input  logic [11:0] char_hgt,
    input  logic [1:0] game_active,
    output logic [11:0] ground_y,
    vga_if.in  vga_in,
    vga_if.out vga_out,
    output logic on_ground
);
    import vga_pkg::*;

    localparam PLAT_COUNT = 4;
    localparam PLAT_THICK = 15;
    localparam PLAT_COLOR = 12'h420;
    localparam PLAT_WIDTH = HOR_PIXELS/5;
    localparam GROUND_PLAT_Y = VER_PIXELS - 52;
    
    logic [11:0] plat_x[PLAT_COUNT] = '{
        0,
        HOR_PIXELS - PLAT_WIDTH,
        (HOR_PIXELS - PLAT_WIDTH)/2,
        0
    };
    
    logic [11:0] plat_y[PLAT_COUNT] = '{
        VER_PIXELS - (VER_PIXELS/4),
        VER_PIXELS - (VER_PIXELS/4),
        VER_PIXELS - (VER_PIXELS/2),
        GROUND_PLAT_Y
    };
    
    logic [11:0] plat_w[PLAT_COUNT] = '{
        PLAT_WIDTH,
        PLAT_WIDTH,
        PLAT_WIDTH,
        HOR_PIXELS
    };
    
    logic [11:0] rgb_nxt;
    logic [11:0] char_y_prev;
    logic [11:0] vcount_reg, hcount_reg;
    logic vsync_reg, hsync_reg, vblnk_reg, hblnk_reg;
    logic [11:0] char_velocity_y;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            char_y_prev     <= 0;
            char_velocity_y <= 0;
        end else begin
            char_y_prev     <= char_y;
            char_velocity_y <= char_y - char_y_prev;
        end
    end

    always_comb begin
        on_ground = 0;
        ground_y  = 0;

        if (game_active == 1) begin
            for (int i = 0; i < PLAT_COUNT; i++) begin
                if ((char_x + char_hgt > plat_x[i]) && 
                    (char_x < plat_x[i] + plat_w[i]) &&
                    (char_y + char_hgt >= plat_y[i] - 1) && 
                    (char_y + char_hgt <= plat_y[i] + 5) &&
                    (char_velocity_y >= 0)) begin
                    on_ground = 1;
                    ground_y  = plat_y[i] - char_hgt;
                    break;
                end
            end
        end
    end

    always_comb begin
        rgb_nxt = vga_in.rgb;

        if (game_active == 1) begin
            for (int i = 0; i < PLAT_COUNT-1; i++) begin
                if (!vga_in.vblnk && !vga_in.hblnk &&
                    vga_in.hcount >= plat_x[i] && 
                    vga_in.hcount < plat_x[i] + plat_w[i] &&
                    vga_in.vcount >= plat_y[i] && 
                    vga_in.vcount < plat_y[i] + PLAT_THICK) begin
                    rgb_nxt = PLAT_COLOR;
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        vcount_reg <= vga_in.vcount;
        vsync_reg  <= vga_in.vsync;
        vblnk_reg  <= vga_in.vblnk;
        hcount_reg <= vga_in.hcount;
        hsync_reg  <= vga_in.hsync;
        hblnk_reg  <= vga_in.hblnk;
    end

    assign vga_out.vcount = vcount_reg;
    assign vga_out.vsync  = vsync_reg;
    assign vga_out.vblnk  = vblnk_reg;
    assign vga_out.hcount = hcount_reg;
    assign vga_out.hsync  = hsync_reg;
    assign vga_out.hblnk  = hblnk_reg;
    assign vga_out.rgb    = rgb_nxt;

endmodule
