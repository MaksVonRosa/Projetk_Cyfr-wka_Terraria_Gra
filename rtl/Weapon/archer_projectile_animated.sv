// module archer_projectile_animated (
//     input  logic        clk,
//     input  logic        rst,
//     input  logic        frame_tick,
//     input  logic [1:0]  game_active,
//     input  logic        mouse_clicked,
//     input  logic [11:0] xpos_MouseCtl,
//     input  logic [11:0] ypos_MouseCtl,
//     input  logic [11:0] pos_x_projectile_offset,
//     input  logic [11:0] pos_y_projectile_offset,
//     input  logic [11:0] boss_x,
//     input  logic [11:0] boss_y,
//     input  logic        boss_alive,

//     output logic [11:0] pos_x_proj,
//     output logic [11:0] pos_y_proj,
//     output logic        projectile_animated,
//     output logic        attack_hit,
//     output logic        proj_direction
// );

//     localparam SCREEN_W = 1024;
//     localparam SCREEN_H = 768;
//     localparam BOSS_LNG = 106;
//     localparam BOSS_HGT = 95;


//     localparam PROJECTILE_SPEED    = 16;   // px / frame
//     localparam PROJECTILE_LIFETIME = 60;   // ile klatek pocisk ma "żyć"

//     logic signed [12:0] dx, dy;
//     logic signed [13:0] step_x, step_y;
//     logic [11:0] start_x, start_y;
//     logic signed [12:0] max_val;

//     logic [7:0] lifetime_cnt;  // licznik życia pocisku

    
//     always_ff @(posedge clk) begin
//         if (rst) begin
//             projectile_animated <= 0;
//             pos_x_proj <= 0;
//             pos_y_proj <= 0;
//             step_x <= 0;
//             step_y <= 0;
//             proj_direction <= 0;
//             dx <= 0;
//             dy <= 0;
//             attack_hit <= 0;
//             start_x <= 0;
//             start_y <= 0;
//             lifetime_cnt <= 0;
//             max_val <= 0;
//         end else begin
//             attack_hit <= 0;

//             if (game_active == 2'd1) begin
//                 // start pocisku – tylko przy kliknięciu i braku aktywnego pocisku
//                 if (mouse_clicked && !projectile_animated) begin
//                     projectile_animated <= 1;
//                     pos_x_proj <= pos_x_projectile_offset;
//                     pos_y_proj <= pos_y_projectile_offset;
//                     start_x <= pos_x_projectile_offset;
//                     start_y <= pos_y_projectile_offset;

//                     dx <= xpos_MouseCtl - pos_x_projectile_offset;
//                     dy <= ypos_MouseCtl - pos_y_projectile_offset;
//                     max_val <= ( (dx < 0 ? -dx : dx) > (dy < 0 ? -dy : dy) ) ? (dx < 0 ? -dx : dx) : (dy < 0 ? -dy : dy);
//                     // normalizacja na stałą prędkość
//                     if (dx == 0 && dy == 0) begin
//                         step_x <= 0;
//                         step_y <= 0;
//                     end else begin
//                         // dzielimy przez max(|dx|,|dy|) aby zachować kierunek
                        
//                         step_x <= (dx * PROJECTILE_SPEED) / max_val;
//                         step_y <= (dy * PROJECTILE_SPEED) / max_val;
//                     end

//                     proj_direction <= (dx < 0);
//                     lifetime_cnt <= PROJECTILE_LIFETIME;
//                 end

//                 // animacja pocisku
//                 else if (frame_tick && projectile_animated) begin
//                     pos_x_proj <= pos_x_proj + step_x;
//                     pos_y_proj <= pos_y_proj + step_y;

//                     if (lifetime_cnt > 0)
//                         lifetime_cnt <= lifetime_cnt - 1;

//                     // kolizja ze ścianą
//                     if (pos_x_proj < 0 || pos_x_proj > SCREEN_W || pos_y_proj < 0 || pos_y_proj > SCREEN_H) begin
//                         projectile_animated <= 0;
//                     end
//                     // kolizja z bossem
//                     else if (boss_alive &&
//                              pos_x_proj >= boss_x-BOSS_LNG && pos_x_proj <= boss_x+BOSS_LNG &&
//                              pos_y_proj >= boss_y-BOSS_HGT && pos_y_proj <= boss_y+BOSS_HGT) begin
//                         projectile_animated <= 0;
//                         attack_hit <= 1;
//                     end
//                     // koniec życia pocisku
//                     else if (lifetime_cnt == 0) begin
//                         projectile_animated <= 0;
//                         pos_x_proj <= pos_x_projectile_offset;
//                         pos_y_proj <= pos_y_projectile_offset;
//                     end
//                 end
//             end else begin
//                 projectile_animated <= 0; // jeśli gra nieaktywna – brak pocisku
//             end
//         end
//     end

// endmodule


module archer_projectile_animated (
    input  logic        clk,
    input  logic        rst,
    input  logic        frame_tick,
    input  logic [1:0]  game_active,
    input  logic        mouse_clicked,
    input  logic [11:0] xpos_MouseCtl,
    input  logic [11:0] ypos_MouseCtl,
    input  logic [11:0] pos_x_projectile_offset,
    input  logic [11:0] pos_y_projectile_offset,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic        boss_alive,

    output logic [11:0] pos_x_proj,
    output logic [11:0] pos_y_proj,
    output logic        projectile_animated,
    output logic        attack_hit,
    output logic        proj_direction
);

    localparam SCREEN_W = 1024;
    localparam SCREEN_H = 768;
    localparam BOSS_LNG = 106;
    localparam BOSS_HGT = 95;

    logic signed [12:0] dx, dy;
    logic signed [13:0] step_x, step_y;
    logic [11:0] start_x, start_y;
    logic signed [12:0] max_val;

    // logic [7:0] lifetime_cnt;  // licznik życia pocisku
    localparam PROJECTILE_SPEED    = 16;   // px / frame
    localparam PROJECTILE_LIFETIME = 60;   // ile klatek pocisk ma "żyć"
    localparam FIRE_COOLDOWN       = 6;    // klatki przerwy między strzałami (~0.1s przy 60Hz)

    logic [7:0] lifetime_cnt;
    logic [7:0] cooldown_cnt;   // licznik przerwy między strzałami

    
    always_ff @(posedge clk) begin
    if (rst) begin
                projectile_animated <= 0;
                pos_x_proj <= 0;
                pos_y_proj <= 0;
                step_x <= 0;
                step_y <= 0;
                proj_direction <= 0;
                dx <= 0;
                dy <= 0;
                attack_hit <= 0;
                start_x <= 0;
                start_y <= 0;
                lifetime_cnt <= 0;
                max_val <= 0;
                cooldown_cnt <= 0; 
    end else begin
        attack_hit <= 0;

        // zmniejszamy cooldown co klatkę
        if (frame_tick && cooldown_cnt > 0)
            cooldown_cnt <= cooldown_cnt - 1;

        if (game_active == 2'd1) begin
            // start pocisku – klik + brak aktywnego pocisku + brak cooldownu
            if (mouse_clicked && /* !projectile_animated && */ cooldown_cnt == 0) begin
                projectile_animated <= 1;
                pos_x_proj <= pos_x_projectile_offset;
                pos_y_proj <= pos_y_projectile_offset;
                start_x <= pos_x_projectile_offset;
                start_y <= pos_y_projectile_offset;

                dx <= xpos_MouseCtl - pos_x_projectile_offset;
                dy <= ypos_MouseCtl - pos_y_projectile_offset;
                max_val <= ( (dx < 0 ? -dx : dx) > (dy < 0 ? -dy : dy) ) ? (dx < 0 ? -dx : dx) : (dy < 0 ? -dy : dy);
                if (dx == 0 && dy == 0) begin
                    step_x <= 0;
                    step_y <= 0;
                end else begin
                
                    step_x <= (dx * PROJECTILE_SPEED) / max_val;
                    step_y <= (dy * PROJECTILE_SPEED) / max_val;
                end

                proj_direction <= (dx < 0);
                lifetime_cnt <= PROJECTILE_LIFETIME;
                cooldown_cnt <= FIRE_COOLDOWN;   // ustawiamy czas przerwy
            end

            // animacja pocisku
            else if (frame_tick && projectile_animated) begin
                pos_x_proj <= pos_x_proj + step_x;
                pos_y_proj <= pos_y_proj + step_y;

                if (lifetime_cnt > 0)
                    lifetime_cnt <= lifetime_cnt - 1;

                if (pos_x_proj < 0 || pos_x_proj > SCREEN_W || pos_y_proj < 0 || pos_y_proj > SCREEN_H) begin
                    projectile_animated <= 0;
                end
                else if (boss_alive &&
                        pos_x_proj >= boss_x-BOSS_LNG && pos_x_proj <= boss_x+BOSS_LNG &&
                        pos_y_proj >= boss_y-BOSS_HGT && pos_y_proj <= boss_y+BOSS_HGT) begin
                    projectile_animated <= 0;
                    attack_hit <= 1;
                end
                else if (lifetime_cnt == 0) begin
                    projectile_animated <= 0;
                end
            end
        end else begin
            projectile_animated <= 0;
        end
    end
    end
endmodule