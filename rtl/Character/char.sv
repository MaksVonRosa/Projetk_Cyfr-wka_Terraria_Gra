module draw_char (
    input  logic clk,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic on_ground,
    input  logic [1:0] char_class,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [11:0] boss_lng,
    input  logic [11:0] boss_hgt,
    input  logic [1:0] game_active,
    input  logic game_start,
    input  logic [3:0] char_hp,
    output logic [3:0] current_health,
    output logic [11:0] ground_lvl,
    output logic [11:0] pos_x_out,
    output logic [11:0] pos_y_out,
    output logic [11:0] char_lng,
    output logic [11:0] char_hgt,
    //test
    output logic [3:0] char_hp_out,
    output logic flip_h_out, 
    //
    vga_if.in  vga_char_in,
    vga_if.out vga_char_out
);
    vga_if vga_char_mid();

    logic [11:0] pos_x, pos_y;
    logic flip_h;

    assign pos_x_out = pos_x;
    assign pos_y_out = pos_y;
    
    //test
    assign char_hp_out = char_hp;
    assign flip_h_out = flip_h;
    //
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
        .ground_lvl(ground_lvl),
        .game_active(game_active),
        .game_start(game_start)
    );

    char_draw u_draw (
        .clk(clk),
        .rst(rst),
        .current_health(current_health),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .char_hgt(char_hgt),
        .char_lng(char_lng),
        .flip_h(flip_h),
        .vga_in(vga_char_in),
        .vga_out(vga_char_mid.out),
        .game_active(game_active),
        .char_class
    );

    hearts_display u_hearts_display (
        .clk(clk),
        .rst(rst),
        .char_hp(char_hp),
        .char_x(pos_x),
        .char_y(pos_y),
        .char_lng(char_lng),
        .char_hgt(char_hgt),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_lng(boss_lng),
        .boss_hgt(boss_hgt),
        .current_health(current_health),
        .vga_in(vga_char_mid.in),
        .vga_out(vga_char_out),
        .game_active(game_active),
        .game_start(game_start)
    );
endmodule
