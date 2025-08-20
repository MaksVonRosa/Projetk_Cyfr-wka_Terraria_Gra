module weapon_top (
    input  logic        clk,
    input  logic        rst,  
    input  logic [11:0] pos_x,    
    input  logic [11:0] pos_y,   
    input  logic        mouse_clicked,
    input  logic [11:0] xpos_MouseCtl,
    input  logic        frame_tick,

    vga_if.in  vga_in,
    vga_if.out vga_out
);

    logic        draw_weapon;
    logic        flip_hor_melee;
    logic [11:0] pos_x_wpn_offset;
    logic [11:0] pos_y_wpn_offset;
    logic signed [11:0] anim_x_offset;


/* Melee 
------------------------------------------------------------------------------
*/
    melee_wpn_ctl u_melee_wpn_ctl (
        .clk,
        .rst,
        .mouse_clicked(mouse_clicked),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .xpos_MouseCtl(xpos_MouseCtl),
        .draw_weapon(draw_weapon),
        .flip_hor_melee(flip_hor_melee),
        .pos_x_wpn_offset(pos_x_wpn_offset),
        .pos_y_wpn_offset(pos_y_wpn_offset)
    );

    melee_wpn_draw u_melee_wpn_draw (
        .clk,
        .rst,
        .pos_x_wpn_offset(pos_x_wpn_offset),
        .pos_y_wpn_offset(pos_y_wpn_offset),
        .flip_hor_melee(flip_hor_melee),
        .mouse_clicked(draw_weapon),   
        .anim_x_offset(anim_x_offset),
        .vga_in(vga_in),
        .vga_out(vga_out)
    );

    melee_wpn_animated u_melee_wpn_animated (
        .clk,
        .rst,
        .frame_tick(frame_tick),
        .mouse_clicked(mouse_clicked),
        .anim_x_offset(anim_x_offset)
    );


/* Archer 
------------------------------------------------------------------------------
*/

archer_wpn_draw u_archer_wpn_draw (
        .clk,
        .rst,
        .pos_x_wpn_offset(pos_x_wpn_offset),
        .pos_y_wpn_offset(pos_y_wpn_offset),
        .flip_hor_melee(flip_hor_melee),
        .mouse_clicked(draw_weapon),   
        .anim_x_offset(anim_x_offset),
        .vga_in(vga_in),
        .vga_out(vga_out)
    );

endmodule
