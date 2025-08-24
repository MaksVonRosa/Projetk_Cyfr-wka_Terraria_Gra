module archer_projectile_ctl #(
    parameter H_RES = 1024,
    parameter V_RES = 768
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        frame_tick,         // 1x na klatkę
    input  logic        fire,               // impuls startu (np. mouse_clicked && char_class==ARCHER)
    input  logic [11:0] start_x,            // zwykle pos_x_archer_offset +/- coś
    input  logic [11:0] start_y,            // zwykle pos_y_archer_offset +/- coś
    input  logic        facing_right,       // kierunek w momencie strzału (zatrzaskiwany)
    input  logic [7:0]  speed_px,           // px/klatkę

    output logic        active,
    output logic [11:0] pos_x_proj,
    output logic [11:0] pos_y_proj,
    output logic        dir_right           // latched direction for draw flip
);

    logic [11:0] x_q, y_q;
    logic        dir_q, active_q;

    always_ff @(posedge clk) begin
        if (rst) begin
            x_q <= '0; y_q <= '0;
            dir_q <= 1'b1;
            active_q <= 1'b0;
        end else begin
            // start nowego pocisku
            if (fire && !active_q) begin
                x_q <= start_x;
                y_q <= start_y;
                dir_q <= facing_right;
                active_q <= 1'b1;
            end else if (frame_tick && active_q) begin
                // ruch
                if (dir_q) x_q <= x_q + speed_px; else x_q <= x_q - speed_px;

                // gaszenie gdy poza ekranem (z lekkim marginesem)
                if (x_q > H_RES+16 || x_q < 16 || y_q > V_RES-1) begin
                    active_q <= 1'b0;
                end
            end
        end
    end

    assign pos_x_proj = x_q;
    assign pos_y_proj = y_q;
    assign dir_right  = dir_q;
    assign active     = active_q;
endmodule
