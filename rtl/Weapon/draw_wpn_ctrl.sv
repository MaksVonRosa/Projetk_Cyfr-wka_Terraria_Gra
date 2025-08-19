module draw_wpn_ctrl (
    input   logic clk,
    input   logic rst,
    input   logic mouse_clicked,
    input   logic [11:0] xpos_MouseCtl,
    input   logic [11:0] pos_x,
    input   logic [11:0] pos_y,    
    input   logic game_active,
    input   logic flip_h,
    input  logic stepleft,
    input  logic stepright,
    output  logic flip_mouse_left_right,
    output  logic draw_weapon,
    output  logic [11:0] pos_x_wpn_offset,
    output  logic [11:0] pos_y_wpn_offset


);
localparam WPN_X_OFFSET = 40;
localparam WPN_Y_OFFSET = 15;

//assign pos_x_wpn_offset  = pos_x + WPN_OFFSET;
assign pos_x_wpn_offset = flip_h ? (pos_x - WPN_X_OFFSET) : (pos_x + WPN_X_OFFSET);
assign pos_y_wpn_offset = pos_y + WPN_Y_OFFSET;

always_ff @(posedge clk) begin
        if (rst) begin
            draw_weapon <= 0;
        end else if (mouse_clicked) begin
            draw_weapon <= 1;
        end else begin
            draw_weapon <= 0;
        end
    end
// import vga_pkg::*;
    
// always_ff @(posedge clk) begin
//         if (rst) flip_h <= 0;
//         else if (game_active == 1) begin
//             if (stepleft)  flip_h <= 1;
//             else if (stepright) flip_h <= 0;
//         end
//     end
//     always_ff @(posedge clk) begin
//         if (rst) begin
//             draw_weapon <= 0;
//             flip_mouse_left_right <= 0;
//             pos_x_wpn_offset <= HOR_PIXELS / 2;
//         end else 
        
//         // if (mouse_clicked) begin
//         //     draw_weapon <= 1;
//         //     if (xpos_MouseCtl > pos_x)
//         //             flip_mouse_left_right <= 0; // broń po prawej
//         //         else
//         //             flip_mouse_left_right <= 1; // broń po lewej (odbicie)
//         //     end

//             if (mouse_clicked) begin
//                 draw_weapon <= 1;           
//                 if (xpos_MouseCtl > pos_x) begin
//                     flip_mouse_left_right  <= 0;// prawa strona
//                     pos_x_wpn_offset  <= pos_x + WPN_OFFSET; // odsuwamy od postaci
//                 end else begin
//                     flip_mouse_left_right  <= 1;                // lewa strona
//                     pos_x_wpn_offset  <= pos_x - WPN_OFFSET; // odsuwamy w lewo
//                 end
//             end

//          else begin
//             draw_weapon <= 0;
//         end
//     end
                

endmodule
