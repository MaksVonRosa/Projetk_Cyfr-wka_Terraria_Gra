module melee_wpn_ctl (
    input   logic clk,
    input   logic rst,
    input   logic mouse_clicked,
    input   logic [11:0] pos_x,
    input   logic [11:0] pos_y,   
    input   logic [11:0] xpos_MouseCtl,   

    output  logic draw_weapon,
    output  logic flip_hor_melee,
    output  logic [11:0] pos_x_wpn_offset,
    output  logic [11:0] pos_y_wpn_offset


);
localparam WPN_X_OFFSET = 40;
localparam WPN_Y_OFFSET = 15;


always_ff @(posedge clk) begin
        if (rst) begin
            draw_weapon <= 0;
            flip_hor_melee <= 0;
        end else if (mouse_clicked) begin
            draw_weapon <= 1;
            if (xpos_MouseCtl > pos_x)begin
                flip_hor_melee <= 0; 
            end else if (xpos_MouseCtl <= pos_x) begin
                flip_hor_melee <= 1; 
            end
            
        end else begin
            draw_weapon <= 0;
        end
    end
    
assign pos_x_wpn_offset = flip_hor_melee ? (pos_x - WPN_X_OFFSET) : (pos_x + WPN_X_OFFSET);
assign pos_y_wpn_offset = pos_y + WPN_Y_OFFSET;            

endmodule
