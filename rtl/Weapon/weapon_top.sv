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
    // logic [11:0] wpn_hgt, wpn_lng;
    // logic anim_active;

    draw_wpn_ctrl u_draw_wpn_ctrl (
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

    wpn_draw_melee u_wpn_draw_melee (
        .clk,
        .rst,
        .pos_x_wpn_offset(pos_x_wpn_offset),
        .pos_y_wpn_offset(pos_y_wpn_offset),
        .flip_hor_melee(flip_hor_melee),
        .mouse_clicked(draw_weapon),  
        // .mouse_clicked(anim_active),  
        .anim_x_offset(anim_x_offset),
        // .wpn_hgt(wpn_hgt),
        // .wpn_lng(wpn_lng),
        .vga_in(vga_in),
        .vga_out(vga_out)
    );

    wpn_melee_attack_anim u_wpn_melee_attack_anim (
        .clk,
        .rst,
        .frame_tick(frame_tick),
        .mouse_clicked(mouse_clicked),
        // .anim_active(anim_active),
        .anim_x_offset(anim_x_offset)
    );
endmodule
