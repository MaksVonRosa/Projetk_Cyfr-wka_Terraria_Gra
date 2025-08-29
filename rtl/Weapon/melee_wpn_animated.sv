//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   melee_wpn_animated
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Melee weapon attack animating module
 */
//////////////////////////////////////////////////////////////////////////////
module melee_wpn_animated 
(
    input  logic clk,
    input  logic rst,
    input  logic frame_tick,       
    input  logic mouse_clicked,
    input  logic alive,
    output logic signed [11:0] anim_x_offset
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam MAX_SWING = 45;    
localparam STEP      = 10;      
localparam integer WAIT_TICKS = 2; 

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
typedef enum logic [1:0] {IDLE, FORWARD, BACKWARD} anim_state_t;
anim_state_t anim_state, next_state;

logic [11:0] anim_count, next_anim_count;     
logic [7:0]  tick_count, next_tick_count;     
logic mouse_clicked_d;
logic mouse_click_pulse;

//------------------------------------------------------------------------------
// Edge detection for mouse click
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst)
        mouse_clicked_d <= 0;
    else if (frame_tick)
        mouse_clicked_d <= mouse_clicked;
end

assign mouse_click_pulse = (mouse_clicked && !mouse_clicked_d);

//------------------------------------------------------------------------------
// Next state logic (combinatorial)
//------------------------------------------------------------------------------
always_comb begin
    next_state = anim_state;
    next_anim_count = anim_count;
    next_tick_count = tick_count;
    
    case (anim_state)
        IDLE: begin
            next_anim_count = 0;
            if (mouse_click_pulse || mouse_clicked) begin
                next_state = FORWARD;
                next_tick_count = 0;
                next_anim_count = 0;
            end
        end

        FORWARD: begin
            if (mouse_click_pulse) begin
                next_tick_count = 0;
                next_anim_count = 0;
                next_state = FORWARD;
            end else if (tick_count < WAIT_TICKS) begin
                next_tick_count = tick_count + 1;
            end else begin
                next_tick_count = 0;
                if (anim_count + STEP < MAX_SWING)
                    next_anim_count = anim_count + STEP;
                else
                    next_state = BACKWARD;
            end
        end

        BACKWARD: begin
            if (mouse_click_pulse) begin
                next_tick_count = 0;
                next_anim_count = 0;
                next_state = FORWARD;
            end else if (tick_count < WAIT_TICKS) begin
                next_tick_count = tick_count + 1;
            end else begin
                next_tick_count = 0;
                if (anim_count > STEP)
                    next_anim_count = anim_count - STEP;
                else begin
                    next_anim_count = 0;
                    if (mouse_clicked)
                        next_state = FORWARD; 
                    else
                        next_state = IDLE;    
                end
            end
        end
    endcase
end

//------------------------------------------------------------------------------
// State register
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        anim_state <= IDLE;
        anim_count <= 0;
        tick_count <= 0;
        anim_x_offset <= 0;
    end else if (frame_tick && alive) begin
        anim_state <= next_state;
        anim_count <= next_anim_count;
        tick_count <= next_tick_count;
        anim_x_offset <= next_anim_count;
    end
end

endmodule