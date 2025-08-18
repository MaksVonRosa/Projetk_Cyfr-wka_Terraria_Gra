module draw_wpn_ctrl (
    input  logic clk,
    input  logic rst,
    input  logic mouse_clicked,
    output logic draw_weapon,
    output logic signed [15:0] angle

);

    import vga_pkg::*;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            draw_weapon <= 0;
        end else if (mouse_clicked) begin
            draw_weapon <= 1;
        end else begin
            draw_weapon <= 0;
        end
    end

//logic signed [15:0] angle;       // kąt w stopniach * np. 256 (fixed-point)
logic direction;                 // 0 = rośnie, 1 = maleje
logic [19:0] slow_cnt; // licznik dzielący zegar

always_ff @(posedge clk) begin
    if (rst) begin
        slow_cnt <= 0;
        angle <= 0;
        direction <= 0;
    end else if (mouse_clicked) begin
        slow_cnt <= slow_cnt + 1;
        if (slow_cnt == 20'd400000) begin // zmiana kąta co ok. 20ms przy 25MHz
            slow_cnt <= 0;
            if (!direction) begin
                angle <= angle + 16'sd4; // prędkość zmiany kąta
                if (angle >= 45*256) direction <= 1;
            end else begin
                angle <= angle - 16'sd4;
                if (angle <= -45*256) direction <= 0;
            end
        end
    end else begin
        angle <= 0;
    end
end

//assign angle = angle_out;

endmodule
