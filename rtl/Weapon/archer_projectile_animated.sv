module archer_projectile_animated (
    input  logic        clk,
    input  logic        rst,
    input  logic        frame_tick,
    input  logic [1:0]  game_active,
    input  logic        mouse_clicked,
    input  logic [11:0] xpos_MouseCtl,
    input  logic [11:0] ypos_MouseCtl,
    input  logic [11:0] pos_x_archer_offset,
    input  logic [11:0] pos_y_archer_offset,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic        boss_alive,

    output logic [11:0] pos_x_proj,
    output logic [11:0] pos_y_proj,
    output logic        projectile_animated,
    output logic        attack_hit,
    output logic        proj_direction,
    output logic [2:0]  direction_sector

);

    localparam SCREEN_W = 1024;
    localparam SCREEN_H = 768;
    localparam BOSS_LNG = 106;
    localparam BOSS_HGT = 95;
    localparam MAX_DISTANCE = 512;  // maksymalna odległość pocisku

    logic signed [12:0] dx, dy;
    logic signed [13:0] step_x, step_y;
    logic [11:0] start_x, start_y;
    logic signed [23:0] dist_squared;
    logic signed [12:0] max_val;
    // logic [2:0] direction_sector;

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
            max_val <= 0;
            dist_squared <= 0;
        end else begin
            // reset jednoklatkowego impulsu
            attack_hit <= 0;

            if (game_active == 2'd1) begin
                // start pocisku – tylko przy kliknięciu i braku aktywnego pocisku
                if (mouse_clicked && !projectile_animated) begin
                    projectile_animated <= 1;
                    pos_x_proj <= pos_x_archer_offset;
                    pos_y_proj <= pos_y_archer_offset;
                    start_x <= pos_x_archer_offset;
                    start_y <= pos_y_archer_offset;

                    dx <= xpos_MouseCtl - pos_x_archer_offset;
                    dy <= ypos_MouseCtl - pos_y_archer_offset;
                    max_val <= ( (dx < 0 ? -dx : dx) > (dy < 0 ? -dy : dy) ) ? 
                            (dx < 0 ? -dx : dx) : (dy < 0 ? -dy : dy);
                    // normalizacja kroku do prędkości ~12 px/frame
                    if (max_val != 0) begin
                        step_x <= (dx * 16) / max_val;  // 8 = prędkość pocisku
                        step_y <= (dy * 16) / max_val;
                    end else begin
                        step_x <= 0;
                        step_y <= 0;
                    end

                    proj_direction <= (dx < 0);
                end

                // animacja pocisku
                else if (frame_tick && projectile_animated) begin
                    pos_x_proj <= pos_x_proj + step_x;
                    pos_y_proj <= pos_y_proj + step_y;

                    // sprawdzanie kolizji z ekranem
                    if (pos_x_proj < 0 || pos_x_proj > SCREEN_W || pos_y_proj < 0 || pos_y_proj > SCREEN_H) begin
                        projectile_animated <= 0;
                    end

                    // sprawdzanie kolizji z bossem
                    else if (boss_alive &&
                             pos_x_proj >= boss_x-BOSS_LNG && pos_x_proj <= boss_x+BOSS_LNG &&
                             pos_y_proj >= boss_y-BOSS_HGT && pos_y_proj <= boss_y+BOSS_HGT) begin
                        projectile_animated <= 0;
                        attack_hit <= 1;
                    end

                    // sprawdzanie maksymalnej odległości
                    dist_squared <= (pos_x_proj - start_x)*(pos_x_proj - start_x) + 
                                   (pos_y_proj - start_y)*(pos_y_proj - start_y);
                    if (dist_squared > MAX_DISTANCE*MAX_DISTANCE) begin
                        projectile_animated <= 0;
                    end
                end
            end else begin
                projectile_animated <= 0; // jeśli gra nieaktywna – brak pocisku
            end
        end
    end



// always_comb begin
//     if      (dx >= 0 && (dy > -dx) && (dy <= dx)) 
//         direction_sector = 3'd0; // prawo
//     else if (dx >= 0 && dy < -dx && dy > dx) 
//         direction_sector = 3'd2; // góra
//     else if (dx <= 0 && (dy >= dx) && (dy < -dx)) 
//         direction_sector = 3'd4; // lewo
//     else if (dx <= 0 && dy <= dx && dy > -dx) 
//         direction_sector = 3'd6; // dół
//     else if (dx > 0 && dy < -dx) 
//         direction_sector = 3'd1; // prawo-góra
//     else if (dx < 0 && dy < dx) 
//         direction_sector = 3'd3; // lewo-góra
//     else if (dx < 0 && dy > -dx) 
//         direction_sector = 3'd5; // lewo-dół
//     else 
//         direction_sector = 3'd7; // prawo-dół
// end
// always_comb begin
//     if      (dy >= -126 && dx > 0 && dy < 126) 
//         direction_sector = 3'd0; // prawo
//     else if (dx >= -169 && dy < 0  && dx < 169) 
//         direction_sector = 3'd2; // góra
//     else if (dy >= -126 && dx < 0 && dy < 126) 
//         direction_sector = 3'd4; // lewo
//     else if (dx >= -169 && dy > 0  && dx < -169) 
//         direction_sector = 3'd6; // dół
//     else if (dx >= 169 && dy >  && dx < 343) 
//         direction_sector = 3'd1; // prawo-góra
//     else if (dx >= -512 && dy < 384 && dy > 126  && dx <= -169) 
//         direction_sector = 3'd3; // lewo-góra
//     else if (dx >= -512 && dy > -384 && dy >= -126  && dx < -169) 
//         direction_sector = 3'd5; // lewo-dół
//     else 
//         direction_sector = 3'd7; // prawo-dół
// end
endmodule

