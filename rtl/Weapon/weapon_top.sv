module weapon_top (
    input  logic        clk,
    input  logic        rst,  
    input  logic [11:0] pos_x,    
    input  logic [11:0] pos_y,   
    input  logic        mouse_clicked,
    input  logic [11:0] xpos_MouseCtl,
    input  logic [11:0] ypos_MouseCtl,
    input  logic        frame_tick,
    input  logic [1:0] game_active,
    input  logic [1:0]  wpn_type,
    input  logic [1:0]  char_class,
    input  logic        projectile_active,
    input  logic        boss_alive,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    output logic        projectile_hit,       

    vga_if.in  vga_in,
    vga_if.out vga_out
);
    import vga_pkg::*;

    vga_if vga_if_melee();
    vga_if vga_if_archer();
    vga_if vga_if_projectile();
    vga_if vga_if_weapon();

    localparam NUM_PROJ = 4;
    logic        draw_weapon;
    logic        flip_hor_melee;
    logic [11:0] pos_x_melee_offset;
    logic [11:0] pos_y_melee_offset;
    logic signed [11:0] anim_x_offset;

    
    logic        flip_hor_archer;
    logic [11:0] pos_x_archer_offset;
    logic [11:0] pos_y_archer_offset;
    logic [11:0] pos_x_projectile_offset;
    logic [11:0] pos_y_projectile_offset;

    logic proj_direction;
    // logic [11:0] pos_x_proj;
    // logic [11:0] pos_y_proj;
    logic [47:0] pos_x_proj;
    logic [47:0] pos_y_proj;

    logic [NUM_PROJ-1:0]projectile_animated;
    logic [2:0]   direction_sector;
    // logic draw_archer_wpn;
    // logic draw_melee_wpn;



//     // --- deklaracje w weapon_top ---
// logic        proj_active;
// logic [11:0] pos_x_proj, pos_y_proj;
// logic        proj_dir_right;

// // “fire” tylko gdy Archer faktycznie strzela (Twój warunek – przykładowo):
// logic fire_archer = mouse_clicked && (char_class == 2'b10) && game_active != 2'b00;

// // kierunek – zapamiętaj “odwrócenie” w chwili strzału:
// logic facing_right = ~flip_hor_archer;



    // wpn_selector u_wpn_selector(
    //     .clk,
    //     .rst,
    //     .pos_x(pos_x),
    //     //.pos_y(pos_y),   
    //     .xpos_MouseCtl(xpos_MouseCtl),  
    //     .mouse_clicked(mouse_clicked), 
    //     .wpn_type(wpn_type),
    //     .draw_archer_wpn(draw_archer_wpn),
    //     .draw_melee_wpn(draw_melee_wpn),
    //     .flip_hor_melee(flip_hor_melee)

    // );


/* Melee 
------------------------------------------------------------------------------
*/
    // melee_wpn_ctl u_melee_wpn_ctl (
    //     .clk,
    //     .rst,
    //     .mouse_clicked(mouse_clicked),
    //     .pos_x(pos_x),
    //     .pos_y(pos_y),
    //     .xpos_MouseCtl(xpos_MouseCtl),
    //     .draw_weapon(draw_weapon),
    //     .flip_hor_melee(flip_hor_melee),
    //     .pos_x_melee_offset(pos_x_archer_offset),
    //     .pos_y_melee_offset(pos_y_archer_offset)
    // );

    // melee_wpn_draw u_melee_wpn_draw (
    //     .clk,
    //     .rst,
    //     // .pos_x_melee_offset(pos_x_melee_offset),
    //     // .pos_y_melee_offset(pos_y_melee_offset),
    //     .pos_x(pos_x),
    //     .pos_y(pos_y),
    //     .flip_hor_melee(flip_hor_melee),
    //     .mouse_clicked(draw_melee_wpn),   
    //     .anim_x_offset(anim_x_offset),
    //     .game_active(game_active),
    //     .vga_in(vga_in),
    //     .vga_out(vga_if_archer.out)
    // );
    weapon_draw u_weapon_draw (
        .clk,
        .rst,
        .pos_x_melee_offset,
        .pos_y_melee_offset,
        .flip_hor_melee(flip_hor_melee),
        .flip_hor_archer(flip_hor_archer),
        .mouse_clicked(draw_weapon),
        .anim_x_offset,
        .game_active,
        .pos_x_archer_offset,
        .pos_y_archer_offset,
        .char_class(char_class),
        .vga_in,
        .vga_out(vga_if_weapon.out)
    );

    melee_wpn_animated u_melee_wpn_animated (
        .clk,
        .rst,
        .frame_tick(frame_tick),
        .mouse_clicked(mouse_clicked),
        .anim_x_offset(anim_x_offset)
    );

    weapon_position u_weapon_position (
            .clk,
            .rst,
            .mouse_clicked(mouse_clicked),
            .pos_x(pos_x),
            .pos_y(pos_y),
            .xpos_MouseCtl(xpos_MouseCtl),
            .draw_weapon(draw_weapon),
            .flip_hor_melee(flip_hor_melee),
            .flip_hor_archer(flip_hor_archer),
            .pos_x_melee_offset(pos_x_melee_offset),
            .pos_y_melee_offset(pos_y_melee_offset),
            .pos_x_archer_offset(pos_x_archer_offset),
            .pos_y_archer_offset(pos_y_archer_offset),
            .pos_x_projectile_offset(pos_x_projectile_offset),
            .pos_y_projectile_offset(pos_y_projectile_offset)
    );
/* Archer 
------------------------------------------------------------------------------
*/
    archer_projectile_draw u_archer_projectile_draw(
        .clk,
        .rst,
        .pos_x_proj(pos_x_proj),
        .pos_y_proj(pos_y_proj),
        // .projectile_active(projectile_active),    
        .projectile_animated(projectile_animated),
        .flip_hor_archer(proj_direction),   
        .game_active(game_active),
        .char_class(char_class),
        // .mouse_clicked(mouse_clicked), 
        .vga_in(vga_if_weapon.in),
        .vga_out
    );

    archer_projectile_animated #(
        .PROJECTILE_COUNT(PROJECTILE_COUNT)
    )u_archer_projectile_animated(
        .clk,
        .rst,
        .frame_tick(frame_tick),          
        .game_active(game_active),
        .mouse_clicked(mouse_clicked),
        .xpos_MouseCtl(xpos_MouseCtl),
        .ypos_MouseCtl(ypos_MouseCtl),
        .pos_x_projectile_offset(pos_x_projectile_offset),
        .pos_y_projectile_offset(pos_y_projectile_offset),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .boss_alive(boss_alive),          
        .pos_x_proj(pos_x_proj),
        .pos_y_proj(pos_y_proj),
        .projectile_hit(projectile_hit),
        // .projectile_active(projectile_active),
        .projectile_animated(projectile_animated)
        // .proj_direction(proj_direction)
    );

    
endmodule
