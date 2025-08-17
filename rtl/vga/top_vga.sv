module top_vga (
    input  logic clk,
    input  logic clk100MHz,
    input  logic rst,
    input  logic stepleft,
    input  logic stepright,
    input  logic stepjump,
    input  logic buttondown,
    output logic on_ground,
    inout  logic ps2_clk,
    inout  logic ps2_data,
    output logic vs,
    output logic hs,
    output logic ground_lvl,
    output logic [11:0] ground_y,
    output logic [11:0] char_x,
    output logic [11:0] char_y,
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b
);
    timeunit 1ns;
    timeprecision 1ps;

    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;
    wire [11:0] char_hgt, char_lng;
    wire [11:0] pos_x_out, pos_y_out; 
    wire [11:0] pos_x_wpn, pos_y_wpn;
    wire [11:0] boss_x, boss_y, boss_hgt, boss_lng;
    wire [3:0] current_health;
    wire [6:0] boss_hp;

    vga_if vga_if_bg();
    vga_if vga_if_char();
    vga_if vga_if_boss();
    vga_if vga_if_plat();
    vga_if vga_if_menu();
    vga_if vga_if_mouse();
    vga_if vga_if_wpn();



    assign vs = vga_if_mouse.vsync;
    assign hs = vga_if_mouse.hsync;
    assign {r,g,b} = vga_if_mouse.rgb;
    assign char_x = pos_x_out;
    assign char_y = pos_y_out;
    logic [11:0] xpos_MouseCtl;
    logic [11:0] ypos_MouseCtl;
    logic mouse_clicked;
    logic draw_weapon;
    logic wpn_hgt;
    logic wpn_lng;


    typedef enum logic [1:0] {
        MENU       = 2'd0,
        GAME       = 2'd1,
        END_SCREEN = 2'd2
    } game_state_t;

    game_state_t game_state;
    always_ff @(posedge clk) begin
        if (rst)
            game_state <= MENU;
        else begin
            case (game_state)
                MENU: if (buttondown) game_state <= GAME;
                GAME: if (current_health == 0 || boss_hp == 0) game_state <= END_SCREEN;
                END_SCREEN: if (buttondown) game_state <= MENU;
            endcase
        end
    end

    logic game_active;
    assign game_active = (game_state == GAME);

    logic show_menu_end;
    assign show_menu_end = (game_state == MENU || game_state == END_SCREEN);

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vcount(vcount_tim),
        .vsync(vsync_tim),
        .vblnk(vblnk_tim),
        .hcount(hcount_tim),
        .hsync(hsync_tim),
        .hblnk(hblnk_tim)
    );

    draw_bg u_draw_bg (
        .clk,
        .rst,
        .vcount_in(vcount_tim),
        .vsync_in(vsync_tim),
        .vblnk_in(vblnk_tim),
        .hcount_in(hcount_tim),
        .hsync_in(hsync_tim),
        .hblnk_in(hblnk_tim),
        .vga_bg_out(vga_if_bg.out)
    );

    game_screen u_game_screen (
        .clk(clk),
        .rst(rst),
        .game_active(game_active),
        .vga_in(vga_if_bg.in),
        .vga_out(vga_if_menu.out)
    );

    platform u_platform (
        .clk,
        .rst,
        .char_x(char_x),
        .char_y(char_y),
        .char_hgt(32),
        .vga_in(vga_if_menu.in),
        .vga_out(vga_if_plat.out),
        .ground_y(ground_y),
        .on_ground(on_ground),
        .game_active(game_active)
    );

    boss_top u_boss (
        .clk(clk),
        .rst(rst),
        .buttondown(buttondown),
        .char_x(char_x),
        .vga_in(vga_if_plat.in),
        .vga_out(vga_if_boss.out),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_hgt(boss_hgt),
        .boss_lng(boss_lng),
        .boss_hp(boss_hp),
        .game_active(game_active)
    );

    draw_char u_char (
        .clk,
        .rst,
        .stepleft,
        .stepright,
        .stepjump,
        .on_ground,
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_lng(boss_lng),
        .boss_hgt(boss_hgt),
        .current_health(current_health),
        .pos_x_out(pos_x_out),
        .pos_y_out(pos_y_out),
        .char_hgt(char_hgt),
        .char_lng(char_lng),
        .ground_lvl(ground_lvl),
        .vga_char_in(vga_if_boss.in),
        .vga_char_out(vga_if_char.out),
        .game_active(game_active)
    );

    draw_wpn_ctrl u_draw_wpn_ctrl (
        .clk,
        .rst,
        .draw_weapon(draw_weapon),
        .mouse_clicked(mouse_clicked)
    );

    wpn_draw_melee_def u_wpn_draw_melee_def (
        .clk(clk),
        .rst(rst),
        .pos_x(xpos_MouseCtl),
        .pos_y(ypos_MouseCtl),
        .mouse_clicked(draw_weapon),
        .flip_h(flip_h),
        .wpn_hgt(wpn_hgt),
        .wpn_lng(wpn_lng),
        .vga_in(vga_if_char.in),
        .vga_out(vga_if_wpn.out)
    );
  
    MouseCtl u_MouseCtl
    (
        .clk(clk100MHz),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl),
        .left(mouse_clicked)
    );

    draw_mouse u_draw_mouse (
        .clk,
        .rst,
        .vga_in_mouse(vga_if_wpn.in),
        .vga_out_mouse(vga_if_mouse.out),
        .xpos(xpos_MouseCtl),
        .ypos(ypos_MouseCtl)

    );

endmodule
