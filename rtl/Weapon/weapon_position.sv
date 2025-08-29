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

    output  logic draw_weapon,
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
// Pipeline registers
//------------------------------------------------------------------------------
logic mouse_clicked_ff;
logic [11:0] pos_x_ff, pos_y_ff, xpos_MouseCtl_ff;
logic flip_hor_melee_ff, flip_hor_archer_ff;
logic draw_weapon_ff;

// Intermediate calculation registers
logic [11:0] pos_x_melee_offset_calc, pos_y_melee_offset_calc;
logic [11:0] pos_x_archer_offset_calc, pos_y_archer_offset_calc;
logic [11:0] pos_x_projectile_offset_calc, pos_y_projectile_offset_calc;

//------------------------------------------------------------------------------
// Input registration stage
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        mouse_clicked_ff <= 0;
        pos_x_ff <= 0;
        pos_y_ff <= 0;
        xpos_MouseCtl_ff <= 0;
    end else begin
        mouse_clicked_ff <= mouse_clicked;
        pos_x_ff <= pos_x;
        pos_y_ff <= pos_y;
        xpos_MouseCtl_ff <= xpos_MouseCtl;
    end
end

//------------------------------------------------------------------------------
// Flip logic calculation (pipelined)
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        flip_hor_melee_ff <= 0;
        flip_hor_archer_ff <= 0;
        draw_weapon_ff <= 0;
    end else begin
        draw_weapon_ff <= mouse_clicked_ff;
        
        if (mouse_clicked_ff) begin
            if (xpos_MouseCtl_ff > pos_x_ff) begin
                flip_hor_melee_ff <= 0; 
                flip_hor_archer_ff <= 0; 
            end else begin
                flip_hor_melee_ff <= 1; 
                flip_hor_archer_ff <= 1; 
            end
        end
    end
end

//------------------------------------------------------------------------------
// Offset calculations (pipelined)
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        pos_x_melee_offset_calc <= 0;
        pos_y_melee_offset_calc <= 0;
        pos_x_archer_offset_calc <= 0;
        pos_y_archer_offset_calc <= 0;
        pos_x_projectile_offset_calc <= 0;
        pos_y_projectile_offset_calc <= 0;
    end else begin
        // Melee offset calculation
        if (flip_hor_melee_ff) begin
            pos_x_melee_offset_calc <= pos_x_ff - MELEE_WPN_X_OFFSET;
        end else begin
            pos_x_melee_offset_calc <= pos_x_ff + MELEE_WPN_X_OFFSET;
        end
        pos_y_melee_offset_calc <= pos_y_ff + MELEE_WPN_Y_OFFSET;
        
        // Archer offset calculation
        if (flip_hor_archer_ff) begin
            pos_x_archer_offset_calc <= pos_x_ff - ARCHER_WPN_X_OFFSET;
        end else begin
            pos_x_archer_offset_calc <= pos_x_ff + ARCHER_WPN_X_OFFSET;
        end
        pos_y_archer_offset_calc <= pos_y_ff + ARCHER_WPN_Y_OFFSET;
        
        // Projectile offset calculation
        if (flip_hor_archer_ff) begin
            pos_x_projectile_offset_calc <= pos_x_ff - PROJECTILE_WPN_X_OFFSET;
        end else begin
            pos_x_projectile_offset_calc <= pos_x_ff + PROJECTILE_WPN_X_OFFSET;
        end
        pos_y_projectile_offset_calc <= pos_y_ff + PROJECTILE_WPN_Y_OFFSET;
    end
end

//------------------------------------------------------------------------------
// Output registration stage
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        draw_weapon <= 0;
        flip_hor_melee <= 0;
        flip_hor_archer <= 0;
        pos_x_melee_offset <= 0;
        pos_y_melee_offset <= 0;
        pos_x_archer_offset <= 0;
        pos_y_archer_offset <= 0;
        pos_x_projectile_offset <= 0;
        pos_y_projectile_offset <= 0;
    end else begin
        draw_weapon <= draw_weapon_ff;
        flip_hor_melee <= flip_hor_melee_ff;
        flip_hor_archer <= flip_hor_archer_ff;
        pos_x_melee_offset <= pos_x_melee_offset_calc;
        pos_y_melee_offset <= pos_y_melee_offset_calc;
        pos_x_archer_offset <= pos_x_archer_offset_calc;
        pos_y_archer_offset <= pos_y_archer_offset_calc;
        pos_x_projectile_offset <= pos_x_projectile_offset_calc;
        pos_y_projectile_offset <= pos_y_projectile_offset_calc;
    end
end

endmodule