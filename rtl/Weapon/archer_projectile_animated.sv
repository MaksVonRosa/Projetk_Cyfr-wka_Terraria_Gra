module archer_projectile_animated #(
    parameter PROJECTILE_COUNT = 4
)(
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

    output logic [PROJECTILE_COUNT-1:0][11:0] pos_x_proj,
    output logic [PROJECTILE_COUNT-1:0][11:0] pos_y_proj,
    output logic [PROJECTILE_COUNT-1:0]       projectile_animated,
    output logic                      projectile_hit
);

    localparam SCREEN_W = 1024;
    localparam SCREEN_H = 768;
    localparam BOSS_LNG = 106;
    localparam BOSS_HGT = 95;

    localparam PROJECTILE_SPEED    = 16;   
    localparam PROJECTILE_LIFETIME = 60;   
    localparam FIRE_COOLDOWN       = 15;    

    // stan pocisków
    logic [PROJECTILE_COUNT-1:0]       active;
    logic signed [13:0]        step_x [PROJECTILE_COUNT];
    logic signed [13:0]        step_y [PROJECTILE_COUNT];
    logic [7:0]                lifetime [PROJECTILE_COUNT];

    logic [7:0] cooldown_cnt;
    logic signed [12:0] dx, dy;
    logic signed [12:0] max_val;

    always_ff @(posedge clk) begin
        if (rst) begin
            active        <= '0;
            pos_x_proj    <= '{default:'0};
            pos_y_proj    <= '{default:'0};
            step_x        <= '{default:'0};
            step_y        <= '{default:'0};
            lifetime      <= '{default:'0};
            cooldown_cnt  <= 0;
            projectile_hit    <= 0;
            dx    <= 0;
            dy    <= 0;
            max_val    <= 0;
        end else begin
            projectile_hit <= 0;

            if (frame_tick && cooldown_cnt > 0)
                cooldown_cnt <= cooldown_cnt - 1;

            if (game_active == 2'd1) begin
                // STRZELANIE
                if (mouse_clicked && cooldown_cnt == 0) begin
                    // znajdź pierwszy wolny slot
                    for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                        if (!active[i]) begin
                            active[i]    <= 1;
                            pos_x_proj[i]<= pos_x_projectile_offset;
                            pos_y_proj[i]<= pos_y_projectile_offset;
                            lifetime[i]  <= PROJECTILE_LIFETIME;

                            // policz krok
                            dx <= xpos_MouseCtl - pos_x_projectile_offset;
                            dy <= ypos_MouseCtl - pos_y_projectile_offset;
                            max_val <= ( (dx < 0 ? -dx : dx) > (dy < 0 ? -dy : dy) ) ? 
                                           (dx < 0 ? -dx : dx) : (dy < 0 ? -dy : dy);

                            if (dx == 0 && dy == 0) begin
                                step_x[i] <= 0;
                                step_y[i] <= 0;
                            end else begin
                                step_x[i] <= (dx * PROJECTILE_SPEED) / max_val;
                                step_y[i] <= (dy * PROJECTILE_SPEED) / max_val;
                            end

                            cooldown_cnt <= FIRE_COOLDOWN;
                            break; // wystrzel tylko jeden pocisk na klik
                        end
                    end
                end

                // ANIMACJA wszystkich pocisków
                if (frame_tick) begin
                    for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                        if (active[i]) begin
                            pos_x_proj[i] <= pos_x_proj[i] + step_x[i];
                            pos_y_proj[i] <= pos_y_proj[i] + step_y[i];

                            if (lifetime[i] > 0)
                                lifetime[i] <= lifetime[i] - 1;

                            // kolizje / koniec życia
                            if (pos_x_proj[i] < 0 || pos_x_proj[i] > SCREEN_W ||
                                pos_y_proj[i] < 0 || pos_y_proj[i] > SCREEN_H ||
                                lifetime[i] == 0) begin
                                active[i] <= 0;
                            end
                            else if (boss_alive &&
                                     pos_x_proj[i] >= boss_x-BOSS_LNG && pos_x_proj[i] <= boss_x+BOSS_LNG &&
                                     pos_y_proj[i] >= boss_y-BOSS_HGT && pos_y_proj[i] <= boss_y+BOSS_HGT) begin
                                active[i] <= 0;
                                projectile_hit <= 1;
                            end
                        end
                    end
                end
            end else begin
                active <= '0; // gra nieaktywna – wyłącz wszystkie pociski
            end
        end
    end

    assign projectile_animated = active;

endmodule
