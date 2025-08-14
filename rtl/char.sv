module draw_char (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic on_ground,
    input  logic [3:0] current_health,
    output logic ground_lvl,
    output logic [11:0] pos_x_out,
    output logic [11:0] pos_y_out,
    output logic [11:0] char_lng,
    output logic [11:0] char_hgt,
    output logic [3:0] char_hp_out,
    vga_if.in  vga_char_in,
    vga_if.out vga_char_out
);

    logic [11:0] pos_x, pos_y;
    logic [3:0] char_hp;
    logic flip_h;

    assign pos_x_out = pos_x;
    assign pos_y_out = pos_y;
    assign char_hp_out = char_hp;

    // Character Movement
    char_ctrl u_ctrl (
        .clk(clk),
        .rst(rst),
        .stepleft(stepleft),
        .stepright(stepright),
        .stepjump(stepjump),
        .on_ground(on_ground),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .flip_h(flip_h),
        .char_hp(char_hp),
        .ground_lvl
    );

    // Character Draw
    char_draw u_draw (
        .clk(clk),
        .rst(rst),
        .current_health,
        .pos_x(pos_x),
        .pos_y(pos_y),
        .char_hgt(char_hgt),
        .char_lng(char_lng),
        .flip_h(flip_h),
        .vga_in(vga_char_in),
        .vga_out(vga_char_out)
    );

endmodule
