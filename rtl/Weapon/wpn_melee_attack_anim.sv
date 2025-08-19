module wpn_melee_attack_anim #(
        // co ile frame_ticków przesuwać
)(
    input  logic clk,
    input  logic rst,
    input  logic frame_tick,       // wolniejszy zegar (np. 60Hz z VGA)
    input  logic mouse_clicked,
    input  logic flip_h,           // kierunek
    output logic signed [11:0] anim_x_offset
);
    localparam MAX_SWING = 45;    // max przesunięcie px
    localparam STEP      = 10;      // krok przesunięcia px  //5
    localparam integer WAIT_TICKS = 2;  // 2
    typedef enum logic [1:0] {IDLE, FORWARD, BACKWARD} anim_state_t;
    anim_state_t anim_state;

    logic [11:0] anim_cnt;     // aktualne przesunięcie
    logic [7:0]  tick_cnt;     // licznik czekania
    logic mouse_clicked_d;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            mouse_clicked_d <= 0;
        else if (frame_tick)
            mouse_clicked_d <= mouse_clicked;
    end

wire mouse_click_pulse = (mouse_clicked && !mouse_clicked_d);


    always_ff @(posedge clk) begin
        if (rst) begin
            anim_state    <= IDLE;
            anim_cnt      <= 0;
            anim_x_offset <= 0;
            tick_cnt      <= 0;
        end else if (frame_tick) begin
            case (anim_state)
            IDLE: begin
                anim_x_offset <= 0;
                anim_cnt      <= 0;
                if (mouse_click_pulse || mouse_clicked) begin
                    anim_state <= FORWARD;
                    tick_cnt   <= 0;
                    anim_cnt   <= 0;
                end
            end

            FORWARD: begin
                if (mouse_click_pulse) begin
                    // restart ataku w trakcie
                    anim_cnt   <= 0;
                    tick_cnt   <= 0;
                    anim_state <= FORWARD;
                end else if (tick_cnt < WAIT_TICKS) begin
                    tick_cnt <= tick_cnt + 1;
                end else begin
                    tick_cnt <= 0;
                    if (anim_cnt + STEP < MAX_SWING)
                        anim_cnt <= anim_cnt + STEP;
                    else
                        anim_state <= BACKWARD;
                end
                anim_x_offset <= anim_cnt;
            end

            BACKWARD: begin
                if (mouse_click_pulse) begin
                    anim_cnt   <= 0;
                    tick_cnt   <= 0;
                    anim_state <= FORWARD;
                end else if (tick_cnt < WAIT_TICKS) begin
                    tick_cnt <= tick_cnt + 1;
                end else begin
                    tick_cnt <= 0;
                    if (anim_cnt > STEP)
                        anim_cnt <= anim_cnt - STEP;
                    else begin
                        anim_cnt   <= 0;
                        if (mouse_clicked)
                            anim_state <= FORWARD; // machaj dalej
                        else
                            anim_state <= IDLE;    // puścił – zatrzymaj
                    end
                end
                anim_x_offset <= anim_cnt;
            end
        endcase

        end
    end

endmodule
