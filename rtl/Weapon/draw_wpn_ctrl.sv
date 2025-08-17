module draw_wpn_ctrl (
    input  logic clk,
    input  logic rst,
    input  logic mouse_clicked,

    output logic draw_weapon
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

endmodule
