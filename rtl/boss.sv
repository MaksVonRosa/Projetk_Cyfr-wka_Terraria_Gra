module draw_boss (
    input  logic clk,
    input  logic rst,
    //input  logic on_ground,
    //input  logic ground_y,
    //output logic ground_lvl,

    vga_if.in  vga_boss_in,
    vga_if.out vga_boss_out
);

    logic [11:0] boss_x, boss_y;
    logic flip_h;

    // // Boss Movement
    // boss_ctrl u_ctrl (
    //     .clk(clk),
    //     .rst(rst),
    //     .stepleft(stepleft),
    //     .stepright(stepright),
    //     .stepjump(stepjump),
    //     .on_ground(on_ground),
    //     .boss_x(boss_x),
    //     .boss_y(boss_y),
    //     .flip_h(flip_h),
    //     .ground_y,
    //     .ground_lvl
    // );

    // Boss Draw
    boss_draw u_boss_draw (
        .clk(clk),
        .rst(rst),
        .vga_in(vga_boss_in),
        .vga_out(vga_boss_out)
    );

endmodule