//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   weapon_position
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Weapon positioning related to character and mouse position module
 */
//////////////////////////////////////////////////////////////////////////////
module weapon_position (
    input   logic clk,
    input   logic rst,
    input   logic mouse_clicked,
    input   logic [11:0] pos_x,
    input   logic [11:0] pos_y,   
    input   logic [11:0] xpos_MouseCtl,   

    output  logic flip_hor_melee,
    output  logic flip_hor_archer,
    output  logic [11:0] pos_x_melee_offset,
    output  logic [11:0] pos_y_melee_offset,
    
    output  logic [11:0] pos_x_archer_offset,
    output  logic [11:0] pos_y_archer_offset,

    output  logic [11:0] pos_x_projectile_offset,
    output  logic [11:0] pos_y_projectile_offset


);
   
//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------   
localparam  MELEE_WPN_X_OFFSET = 40;
localparam  MELEE_WPN_Y_OFFSET = 15;

localparam ARCHER_WPN_X_OFFSET = 10;
localparam ARCHER_WPN_Y_OFFSET = 12;

localparam PROJECTILE_WPN_X_OFFSET = 30;
localparam PROJECTILE_WPN_Y_OFFSET = -4;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
   
always_ff @(posedge clk) begin
        if (rst) begin
            flip_hor_melee <= 0;
            flip_hor_archer <= 0;
        end else if (mouse_clicked) begin
            if (xpos_MouseCtl > pos_x)begin
                flip_hor_melee <= 0; 
                flip_hor_archer <= 0; 
            end else if (xpos_MouseCtl <= pos_x) begin
                flip_hor_melee <= 1; 
                flip_hor_archer <= 1; 
            end
            
        end else begin
        end
    end
    
assign pos_x_melee_offset = flip_hor_melee ? (pos_x -  MELEE_WPN_X_OFFSET) : (pos_x +  MELEE_WPN_X_OFFSET);
assign pos_y_melee_offset = pos_y + MELEE_WPN_Y_OFFSET;            


assign pos_x_archer_offset = flip_hor_archer ? (pos_x - ARCHER_WPN_X_OFFSET) : (pos_x + ARCHER_WPN_X_OFFSET);
assign pos_y_archer_offset = pos_y + ARCHER_WPN_Y_OFFSET;

assign pos_x_projectile_offset = flip_hor_archer ? (pos_x - PROJECTILE_WPN_X_OFFSET) : (pos_x + PROJECTILE_WPN_X_OFFSET);
assign pos_y_projectile_offset = pos_y + PROJECTILE_WPN_Y_OFFSET;

endmodule
