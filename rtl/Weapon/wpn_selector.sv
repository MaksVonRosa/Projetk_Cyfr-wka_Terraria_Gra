module wpn_selector (
    input   logic clk,
    input   logic rst,
    input   logic mouse_clicked,
    input   logic [11:0] pos_x,
    //input   logic [11:0] pos_y,   
    input   logic [11:0] xpos_MouseCtl,   
    input   logic [1:0]  wpn_type,

    output  logic draw_archer_wpn,
    output  logic draw_melee_wpn,
    output  logic flip_hor_melee

);

    always_ff @(posedge clk) begin
    if (rst) begin
        draw_melee_wpn      <= 0;
        draw_archer_wpn     <= 0;
        flip_hor_melee  <= 0;
    end else if (mouse_clicked) begin
        // Reset sygnałów przy każdym kliknięciu
        draw_melee_wpn  <= 0;
        draw_archer_wpn <= 0;

        case (wpn_type)
            2'b00: begin // melee
                draw_melee_wpn <= 1;
                if (xpos_MouseCtl > pos_x) 
                    flip_hor_melee <= 0; 
                else 
                    flip_hor_melee <= 1; 
            end

            2'b01: begin // archer
                draw_archer_wpn <= 1;
                if (xpos_MouseCtl > pos_x) 
                    flip_hor_melee <= 0; 
                else 
                    flip_hor_melee <= 1; 
            end

            default: begin // null
                draw_melee_wpn     <= 0;
                draw_archer_wpn    <= 0;
                flip_hor_melee <= 0;
            end
        endcase
    end else begin
        draw_melee_wpn     <= 0;
        draw_archer_wpn    <= 0;
    end
end
  
endmodule
