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
    anim_state_t anim_state;

    logic [11:0] anim_count;     
    logic [7:0]  tick_count;     
    logic mouse_clicked_d;
//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (rst)
            mouse_clicked_d <= 0;
        else if (frame_tick)
            mouse_clicked_d <= mouse_clicked;
    end

wire mouse_click_pulse = (mouse_clicked && !mouse_clicked_d);

    always_ff @(posedge clk) begin
        if (rst) begin
            anim_state    <= IDLE;
            anim_count      <= 0;
            anim_x_offset <= 0;
            tick_count      <= 0;
        end else if (frame_tick && alive) begin
            case (anim_state)
            IDLE: begin
                anim_x_offset <= 0;
                anim_count      <= 0;
                if (mouse_click_pulse || mouse_clicked) begin
                    anim_state <= FORWARD;
                    tick_count   <= 0;
                    anim_count   <= 0;
                end
            end

            FORWARD: begin
                if (mouse_click_pulse) begin
                    anim_count   <= 0;
                    tick_count   <= 0;
                    anim_state <= FORWARD;
                end else if (tick_count < WAIT_TICKS) begin
                    tick_count <= tick_count + 1;
                end else begin
                    tick_count <= 0;
                    if (anim_count + STEP < MAX_SWING)
                        anim_count <= anim_count + STEP;
                    else
                        anim_state <= BACKWARD;
                end
                anim_x_offset <= anim_count;
            end

            BACKWARD: begin
                if (mouse_click_pulse) begin
                    anim_count   <= 0;
                    tick_count   <= 0;
                    anim_state <= FORWARD;
                end else if (tick_count < WAIT_TICKS) begin
                    tick_count <= tick_count + 1;
                end else begin
                    tick_count <= 0;
                    if (anim_count > STEP)
                        anim_count <= anim_count - STEP;
                    else begin
                        anim_count   <= 0;
                        if (mouse_clicked)
                            anim_state <= FORWARD; 
                        else
                            anim_state <= IDLE;    
                    end
                end
                anim_x_offset <= anim_count;
            end
        endcase

        end
    end

endmodule
