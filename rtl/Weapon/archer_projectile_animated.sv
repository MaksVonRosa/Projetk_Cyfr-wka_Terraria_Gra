//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   archer_projectile_draw
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Projectile of archer weapon attack animating and collision with boss module
 */
//////////////////////////////////////////////////////////////////////////////
module archer_projectile_animated #(
    parameter PROJECTILE_COUNT = 4
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        frame_tick,
    input  logic [1:0]  game_active,
    input  logic        mouse_clicked,
    input  logic [11:0] xpos_MouseCtl,
    input  logic [11:0] ypos_MouseCtl,
    input  logic [11:0] pos_x_projectile_offset,
    input  logic [11:0] pos_y_projectile_offset,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic        boss_alive,
    input  logic        alive,

    output logic [PROJECTILE_COUNT-1:0][11:0] pos_x_proj,
    output logic [PROJECTILE_COUNT-1:0][11:0] pos_y_proj,
    output logic [PROJECTILE_COUNT-1:0]       projectile_animated,
    output logic                      projectile_hit
);
    import vga_pkg::*;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
 
    localparam PROJECTILE_SPEED    = 32;   
    localparam PROJECTILE_LIFETIME = 64;   
    localparam FIRE_COOLDOWN       = 25;    

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

    logic [PROJECTILE_COUNT-1:0]       projectile_active;
    logic signed [13:0]        step_x [PROJECTILE_COUNT];
    logic signed [13:0]        step_y [PROJECTILE_COUNT];
    logic [7:0]                lifetime [PROJECTILE_COUNT];

    logic [7:0] cooldown_count;
    logic signed [12:0] dx, dy;
    logic signed [12:0] max_val;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
   
    // always_ff @(posedge clk) begin
    //     if (rst) begin
    //         projectile_active        <= '0;
    //         pos_x_proj    <= '{default:'0};
    //         pos_y_proj    <= '{default:'0};
    //         step_x        <= '{default:'0};
    //         step_y        <= '{default:'0};
    //         lifetime      <= '{default:'0};
    //         cooldown_count  <= 0;
    //         projectile_hit    <= 0;
    //         dx    <= 0;
    //         dy    <= 0;
    //         max_val    <= 0;
    //     end else begin
    //         projectile_hit <= 0;

    //         if (frame_tick && cooldown_count > 0)
    //             cooldown_count <= cooldown_count - 1;

    //         if (game_active == 2'd1 && alive) begin
    //             if (mouse_clicked && cooldown_count == 0) begin
    //                 for (int i = 0; i < PROJECTILE_COUNT; i++) begin
    //                     if (!projectile_active[i]) begin
    //                         projectile_active[i]    <= 1;
    //                         pos_x_proj[i]<= pos_x_projectile_offset;
    //                         pos_y_proj[i]<= pos_y_projectile_offset;
    //                         lifetime[i]  <= PROJECTILE_LIFETIME;

    //                         dx <= xpos_MouseCtl - pos_x_projectile_offset;
    //                         dy <= ypos_MouseCtl - pos_y_projectile_offset;
    //                         max_val <= ( (dx < 0 ? -dx : dx) > (dy < 0 ? -dy : dy) ) ? 
    //                                        (dx < 0 ? -dx : dx) : (dy < 0 ? -dy : dy);

    //                         if (dx == 0 && dy == 0) begin
    //                             step_x[i] <= 0;
    //                             step_y[i] <= 0;
    //                         end else begin
    //                             step_x[i] <= (dx * PROJECTILE_SPEED) / max_val;
    //                             step_y[i] <= (dy * PROJECTILE_SPEED) / max_val;
    //                         end

    //                         cooldown_count <= FIRE_COOLDOWN;
    //                         break; 
    //                     end
    //                 end
    //             end

    //             if (frame_tick) begin
    //                 for (int i = 0; i < PROJECTILE_COUNT; i++) begin
    //                     if (projectile_active[i]) begin
    //                         pos_x_proj[i] <= pos_x_proj[i] + step_x[i];
    //                         pos_y_proj[i] <= pos_y_proj[i] + step_y[i];

    //                         if (lifetime[i] > 0)
    //                             lifetime[i] <= lifetime[i] - 1;

    //                         if (pos_x_proj[i] < 0 || pos_x_proj[i] >  HOR_PIXELS ||
    //                             pos_y_proj[i] < 0 || pos_y_proj[i] >  VER_PIXELS ||
    //                             lifetime[i] == 0) begin
    //                             projectile_active[i] <= 0;
    //                         end
    //                         else if (boss_alive &&
    //                                  pos_x_proj[i] >= boss_x-BOSS_LNG && pos_x_proj[i] <= boss_x+BOSS_LNG &&
    //                                  pos_y_proj[i] >= boss_y-BOSS_HGT && pos_y_proj[i] <= boss_y+BOSS_HGT) begin
    //                             projectile_active[i] <= 0;
    //                             projectile_hit <= 1;
    //                         end
    //                     end
    //                 end
    //             end
    //         end else begin
    //             projectile_active <= '0; 
    //         end
    //     end
    // end

    assign projectile_animated = projectile_active;
    assign projectile_hit = 1;
    assign pos_x_proj = 200;
    assign pos_y_proj = 200;

    
endmodule
// module archer_projectile_animated #(
//     parameter PROJECTILE_COUNT = 4
// )(
//     input  logic        clk,
//     input  logic        rst,                // synchronous reset (active high as w oryginale)
//     input  logic        frame_tick,
//     input  logic [1:0]  game_active,
//     input  logic        mouse_clicked,
//     input  logic [11:0] xpos_MouseCtl,
//     input  logic [11:0] ypos_MouseCtl,
//     input  logic [11:0] pos_x_projectile_offset,
//     input  logic [11:0] pos_y_projectile_offset,
//     input  logic [11:0] boss_x,
//     input  logic [11:0] boss_y,
//     input  logic        boss_alive,
//     input  logic        alive,

//     output logic [PROJECTILE_COUNT-1:0][11:0] pos_x_proj,
//     output logic [PROJECTILE_COUNT-1:0][11:0] pos_y_proj,
//     output logic [PROJECTILE_COUNT-1:0]       projectile_animated,
//     output logic                      projectile_hit
// );
//     import vga_pkg::*;

//     // local params (przechowane tak jak w Twoim oryginale)
//     localparam int PROJECTILE_SPEED    = 30;
//     localparam int PROJECTILE_LIFETIME = 60;
//     localparam int FIRE_COOLDOWN       = 25;

//     // internal storage (all registers updated in single always_ff)
//     logic [PROJECTILE_COUNT-1:0]       projectile_active;
//     logic signed [13:0]                step_x [PROJECTILE_COUNT];
//     logic signed [13:0]                step_y [PROJECTILE_COUNT];
//     logic [7:0]                        lifetime [PROJECTILE_COUNT];
//     logic [7:0]                        cooldown_count;

//     // pipeline registers (registered values used to compute step on next clock)
//     logic signed [15:0] dx_mul_r;   // dx * speed (registered)
//     logic signed [15:0] dy_mul_r;
//     logic signed [13:0] max_val_r;
//     logic                 compute_valid_r;
//     logic [$clog2(PROJECTILE_COUNT)-1:0] fire_slot_idx_r;
//     logic                 fire_slot_valid_r;

//     // temporaries for next-cycle captures (will be assigned to *_r at end of cycle)
//     logic signed [15:0] dx_mul_next;
//     logic signed [15:0] dy_mul_next;
//     logic signed [13:0] max_val_next;
//     logic                 compute_valid_next;
//     logic [$clog2(PROJECTILE_COUNT)-1:0] fire_slot_idx_next;
//     logic                 fire_slot_valid_next;

//     // helper signed temps
//     logic signed [13:0] dx_tmp;
//     logic signed [13:0] dy_tmp;
//     logic signed [13:0] adx;
//     logic signed [13:0] ady;
//                 logic signed [13:0] denom;
//                 logic signed [13:0] sx;
//                 logic signed [13:0] sy;

//     // single synchronous process — all reg writes happen tutaj
//     always_ff @(posedge clk) begin
//         if (rst) begin
//             // reset everything
//             projectile_active     <= '0;
//             for (int i=0; i<PROJECTILE_COUNT; i++) begin
//                 pos_x_proj[i] <= '0;
//                 pos_y_proj[i] <= '0;
//                 step_x[i]     <= '0;
//                 step_y[i]     <= '0;
//                 lifetime[i]   <= '0;
//             end
//             cooldown_count     <= '0;
//             projectile_hit     <= 1'b0;

//             // pipeline regs reset
//             dx_mul_r           <= '0;
//             dy_mul_r           <= '0;
//             max_val_r          <= '0;
//             compute_valid_r    <= 1'b0;
//             fire_slot_idx_r    <= '0;
//             fire_slot_valid_r  <= 1'b0;

//             // next regs init
//             dx_mul_next        <= '0;
//             dy_mul_next        <= '0;
//             max_val_next       <= '0;
//             compute_valid_next <= 1'b0;
//             fire_slot_idx_next <= '0;
//             fire_slot_valid_next <= 1'b0;
//         end else begin
//             // default next pipeline values (will be overwritten if capture occurs)
//             compute_valid_next <= 1'b0;
//             fire_slot_valid_next <= 1'b0;
//             dx_mul_next <= dx_mul_r;
//             dy_mul_next <= dy_mul_r;
//             max_val_next <= max_val_r;
//             fire_slot_idx_next <= fire_slot_idx_r;

//             // clear projectile_hit by default each tick (set later if collision)
//             projectile_hit <= 1'b0;

//             // --- FIRST: commit any pending compute from previous cycle (pipeline stage) ---
//             if (compute_valid_r && fire_slot_valid_r) begin
//                 int idx = fire_slot_idx_r;
//                 // ensure max_val_r != 0
//                 denom <= (max_val_r == 0) ? 14'sd1 : max_val_r;

//                 // integer division (registered operands) -> result assigned to step registers
//                 sx <= dx_mul_r / denom;
//                 sy <= dy_mul_r / denom;

//                 // clamp to signed 14-bit range
//                 if (sx > 14'sd8191) sx <= 14'sd8191; // very wide clamp (but still safe)
//                 if (sx < -14'sd8192) sx <= -14'sd8192;
//                 if (sy > 14'sd8191) sy <= 14'sd8191;
//                 if (sy < -14'sd8192) sy <= -14'sd8192;

//                 step_x[idx] <= sx;
//                 step_y[idx] <= sy;

//                 // initialize projectile state
//                 projectile_active[idx] <= 1'b1;
//                 pos_x_proj[idx] <= pos_x_projectile_offset;
//                 pos_y_proj[idx] <= pos_y_projectile_offset;
//                 lifetime[idx] <= PROJECTILE_LIFETIME;
//             end

//             // --- SECOND: update existing active projectiles on frame_tick (movement/lifetime/collision) ---
//             if (frame_tick) begin
//                 // decrement cooldown if active
//                 if (cooldown_count > 0)
//                     cooldown_count <= cooldown_count - 1;

//                 for (int i = 0; i < PROJECTILE_COUNT; i++) begin
//                     if (projectile_active[i]) begin
//                         // update positions using registered steps - short adder per projectile
//                         pos_x_proj[i] <= $signed(pos_x_proj[i]) + $signed(step_x[i]);
//                         pos_y_proj[i] <= $signed(pos_y_proj[i]) + $signed(step_y[i]);

//                         // lifetime decrement
//                         if (lifetime[i] > 0)
//                             lifetime[i] <= lifetime[i] - 1'b1;

//                         // bounds / lifetime check
//                         if ($signed(pos_x_proj[i]) < 0 || pos_x_proj[i] > HOR_PIXELS ||
//                             $signed(pos_y_proj[i]) < 0 || pos_y_proj[i] > VER_PIXELS ||
//                             lifetime[i] == 8'd0) begin
//                             projectile_active[i] <= 1'b0;
//                         end
//                         // collision with boss
//                         else if (boss_alive &&
//                                  pos_x_proj[i] >= boss_x - BOSS_LNG && pos_x_proj[i] <= boss_x + BOSS_LNG &&
//                                  pos_y_proj[i] >= boss_y - BOSS_HGT && pos_y_proj[i] <= boss_y + BOSS_HGT) begin
//                             projectile_active[i] <= 1'b0;
//                             projectile_hit <= 1'b1;
//                         end
//                     end
//                 end
//             end else begin
//                 // if not frame_tick, still decrement nothing; cooldown will be decremented only on frame_tick per original
//             end

//             // --- THIRD: handle mouse click / firing capture (setup pipeline for next cycle) ---
//             // This uses current projectile_active state (before any new activation in this cycle)
//             if (game_active == 2'd1 && alive) begin
//                 if (mouse_clicked && cooldown_count == 0) begin
//                     // find first free slot
//                     logic found;
//                     found = 1'b0;
//                     for (int j = 0; j < PROJECTILE_COUNT; j++) begin
//                         if (!projectile_active[j] && !found) begin
//                             // capture dx/dy using signed arithmetic
//                             dx_tmp <= $signed({1'b0, xpos_MouseCtl}) - $signed({1'b0, pos_x_projectile_offset});
//                             dy_tmp <= $signed({1'b0, ypos_MouseCtl}) - $signed({1'b0, pos_y_projectile_offset});
//                             adx <= (dx_tmp < 0) ? -dx_tmp : dx_tmp;
//                             ady <= (dy_tmp < 0) ? -dy_tmp : dy_tmp;

//                             // store pre-multiplied values for next-cycle division
//                             dx_mul_next <= dx_tmp * PROJECTILE_SPEED;
//                             dy_mul_next <= dy_tmp * PROJECTILE_SPEED;
//                             max_val_next <= (adx > ady) ? adx : ady;
//                             if (max_val_next == 14'sd0) max_val_next <= 14'sd1; // avoid divide by zero

//                             compute_valid_next <= 1'b1;
//                             fire_slot_idx_next <= j[$clog2(PROJECTILE_COUNT)-1:0];
//                             fire_slot_valid_next <= 1'b1;

//                             cooldown_count <= FIRE_COOLDOWN;
//                             found = 1'b1;
//                         end
//                     end
//                 end
//             end else begin
//                 // if game not active or not alive, optionally clear active projectiles (original did)
//                 // original code set projectile_active <= '0 when not active; preserve that behaviour:
//                 for (int k=0; k<PROJECTILE_COUNT; k++) begin
//                     projectile_active[k] <= 1'b0;
//                 end
//             end

//             // --- FINALLY: update pipeline registers for next cycle ---
//             dx_mul_r         <= dx_mul_next;
//             dy_mul_r         <= dy_mul_next;
//             max_val_r        <= max_val_next;
//             compute_valid_r  <= compute_valid_next;
//             fire_slot_idx_r  <= fire_slot_idx_next;
//             fire_slot_valid_r<= fire_slot_valid_next;

//             // ensure next flags cleared unless set above
//             // (already defaulted earlier in this reset)
//         end
//     end

//     // outputs
//     assign projectile_animated = projectile_active;

// endmodule
