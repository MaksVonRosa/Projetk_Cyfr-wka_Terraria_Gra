//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   archer_projectile_animated
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Projectile of archer weapon attack animating and collision with boss module
 */
//////////////////////////////////////////////////////////////////////////////
module archer_projectile_animated #(
    parameter PROJECTILE_COUNT = 4
)(
    input logic clk,
    input logic rst,
    input logic frame_tick,
    input logic [1:0] game_active,
    input logic mouse_clicked,
    input logic [11:0] xpos_MouseCtl,
    input logic [11:0] ypos_MouseCtl,
    input logic [11:0] pos_x_projectile_offset,
    input logic [11:0] pos_y_projectile_offset,
    input logic [11:0] boss_x,
    input logic [11:0] boss_y,
    input logic boss_alive,
    input logic alive,
    output logic [PROJECTILE_COUNT-1:0][11:0] pos_x_proj,
    output logic [PROJECTILE_COUNT-1:0][11:0] pos_y_proj,
    output logic [PROJECTILE_COUNT-1:0] projectile_animated,
    output logic projectile_hit
);

import vga_pkg::*;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam PROJECTILE_SPEED = 30;
localparam PROJECTILE_LIFETIME = 60;
localparam FIRE_COOLDOWN = 25;

// Use lookup table for division approximation
localparam LUT_SIZE = 256;
logic [7:0] reciprocal_lut [0:LUT_SIZE-1];

// Initialize reciprocal LUT (pre-computed values)
initial begin
    for (int i = 1; i < LUT_SIZE; i++) begin
        reciprocal_lut[i] = (PROJECTILE_SPEED * 128) / i; // Fixed point 8.8 format
    end
    reciprocal_lut[0] = 0;
end

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [PROJECTILE_COUNT-1:0] projectile_active;
logic signed [11:0] step_x [PROJECTILE_COUNT];
logic signed [11:0] step_y [PROJECTILE_COUNT];
logic [7:0] lifetime [PROJECTILE_COUNT];
logic [7:0] cooldown_count;

// Fire request pipeline
logic fire_request;
logic [11:0] target_x, target_y;
logic [11:0] fire_pos_x, fire_pos_y;

// Collision detection signals
logic [PROJECTILE_COUNT-1:0] hit_detect;

// Pipeline registers for direction calculation
logic signed [12:0] dx, dy;
logic [7:0] max_abs;
logic [7:0] reciprocal;
logic fire_request_stage1, fire_request_stage2;

//------------------------------------------------------------------------------
// Fire request registration
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        fire_request <= 0;
        target_x <= 0;
        target_y <= 0;
        fire_pos_x <= 0;
        fire_pos_y <= 0;
    end else if (mouse_clicked && cooldown_count == 0 && game_active == 2'd1 && alive) begin
        fire_request <= 1;
        target_x <= xpos_MouseCtl;
        target_y <= ypos_MouseCtl;
        fire_pos_x <= pos_x_projectile_offset;
        fire_pos_y <= pos_y_projectile_offset;
    end else begin
        fire_request <= 0;
    end
end

//------------------------------------------------------------------------------
// Pipeline stage 1: Calculate direction
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        fire_request_stage1 <= 0;
        dx <= 0;
        dy <= 0;
    end else begin
        fire_request_stage1 <= fire_request;
        
        if (fire_request) begin
            // Calculate delta values IMMEDIATELY when fire is requested
            dx <= target_x - fire_pos_x;
            dy <= target_y - fire_pos_y;
        end
    end
end

//------------------------------------------------------------------------------
// Pipeline stage 2: Calculate absolute values
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        fire_request_stage2 <= 0;
        max_abs <= 0;
    end else begin
        fire_request_stage2 <= fire_request_stage1;
        
        if (fire_request_stage1) begin
            logic signed [12:0] abs_dx, abs_dy;
            
            abs_dx = (dx < 0) ? -dx : dx;
            abs_dy = (dy < 0) ? -dy : dy;
            max_abs <= (abs_dx > abs_dy) ? abs_dx[7:0] : abs_dy[7:0];
        end
    end
end

//------------------------------------------------------------------------------
// Pipeline stage 3: Lookup reciprocal
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        reciprocal <= 0;
    end else if (fire_request_stage2) begin
        if (max_abs < LUT_SIZE && max_abs != 0) begin
            reciprocal <= reciprocal_lut[max_abs];
        end else if (max_abs != 0) begin
            reciprocal <= (PROJECTILE_SPEED * 128) / max_abs; // Fallback
        end else begin
            reciprocal <= 0;
        end
    end
end

//------------------------------------------------------------------------------
// Projectile management
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        projectile_active <= '0;
        pos_x_proj <= '{default:'0};
        pos_y_proj <= '{default:'0};
        step_x <= '{default:'0};
        step_y <= '{default:'0};
        lifetime <= '{default:'0};
        cooldown_count <= 0;
        projectile_hit <= 0;
        hit_detect <= '0;
    end else begin
        projectile_hit <= |hit_detect;
        hit_detect <= '0;
        
        // Cooldown counter
        if (frame_tick && cooldown_count > 0) begin
            cooldown_count <= cooldown_count - 1;
        end
        
        // Initialize new projectile (after pipeline completion)
        if (fire_request_stage2 && max_abs != 0 && reciprocal != 0) begin
            for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                if (!projectile_active[i]) begin
                    projectile_active[i] <= 1;
                    pos_x_proj[i] <= fire_pos_x;
                    pos_y_proj[i] <= fire_pos_y;
                    lifetime[i] <= PROJECTILE_LIFETIME;
                    
                    // Calculate steps using fixed-point multiplication
                    step_x[i] <= (dx * reciprocal) >>> 7; // Fixed-point adjustment
                    step_y[i] <= (dy * reciprocal) >>> 7; // Fixed-point adjustment
                    
                    cooldown_count <= FIRE_COOLDOWN;
                    break;
                end
            end
        end
        
        // Update projectiles
        if (frame_tick) begin
            for (int i = 0; i < PROJECTILE_COUNT; i++) begin
                if (projectile_active[i]) begin
                    // Position update
                    pos_x_proj[i] <= pos_x_proj[i] + step_x[i];
                    pos_y_proj[i] <= pos_y_proj[i] + step_y[i];
                    
                    // Lifetime management
                    if (lifetime[i] > 0) begin
                        lifetime[i] <= lifetime[i] - 1;
                    end
                    
                    // Boundary check
                    if (pos_x_proj[i] < 0 || pos_x_proj[i] > HOR_PIXELS || 
                        pos_y_proj[i] < 0 || pos_y_proj[i] > VER_PIXELS || 
                        lifetime[i] == 1) begin
                        projectile_active[i] <= 0;
                    end
                    
                    // Collision detection
                    if (boss_alive && 
                        pos_x_proj[i] >= boss_x - BOSS_LNG && 
                        pos_x_proj[i] <= boss_x + BOSS_LNG && 
                        pos_y_proj[i] >= boss_y - BOSS_HGT && 
                        pos_y_proj[i] <= boss_y + BOSS_HGT) begin
                        hit_detect[i] <= 1;
                        projectile_active[i] <= 0;
                    end
                end
            end
        end
        
        // Reset projectiles when game not active
        if (game_active != 2'd1 || !alive) begin
            projectile_active <= '0;
        end
    end
end

assign projectile_animated = projectile_active;

endmodule