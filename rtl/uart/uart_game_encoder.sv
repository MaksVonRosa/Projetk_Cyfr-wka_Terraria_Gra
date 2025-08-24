module uart_game_encoder #(
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    input  logic [3:0]  char_hp,
    input  logic [3:0]  char_aggro,
    input  logic        flip_h,
    input  logic [1:0]  char_class,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic [6:0]  boss_hp,
    input  logic tx_ready,
    input  logic tx_full,
    output logic [DATA_WIDTH-1:0] uart_data,
    output logic uart_wr
);

    typedef enum logic [1:0] {IDLE=0, SENDING=1} state_t;
    state_t current_state, next_state;

    logic [4:0] send_step;

    logic [11:0] prev_char_x, prev_char_y;
    logic [3:0]  prev_char_hp, prev_char_aggro;
    logic        prev_flip_h;
    logic [1:0]  prev_char_class;
    logic [11:0] prev_boss_x, prev_boss_y;
    logic [6:0]  prev_boss_hp;

    logic data_changed;

    always_comb begin
        data_changed = (char_x != prev_char_x) ||
                       (char_y != prev_char_y) ||
                       (char_hp != prev_char_hp) ||
                       (char_aggro != prev_char_aggro) ||
                       (flip_h != prev_flip_h) ||
                       (char_class != prev_char_class) ||
                       (boss_x != prev_boss_x) ||
                       (boss_y != prev_boss_y) ||
                       (boss_hp != prev_boss_hp);
    end

    logic [DATA_WIDTH-1:0] send_array [0:14];
    always_comb begin
        send_array[0]  = "D"; 
        send_array[1]  = char_x[7:0];
        send_array[2]  = {4'b0, char_x[11:8]};
        send_array[3]  = char_y[7:0];
        send_array[4]  = {4'b0, char_y[11:8]};
        send_array[5]  = char_hp;
        send_array[6]  = char_aggro;
        send_array[7]  = {7'b0, flip_h};
        send_array[8]  = char_class;
        send_array[9]  = "B";
        send_array[10] = boss_x[7:0];
        send_array[11] = {4'b0, boss_x[11:8]};
        send_array[12] = boss_y[7:0];
        send_array[13] = {4'b0, boss_y[11:8]};
        send_array[14] = boss_hp;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_char_x <= 0; prev_char_y <= 0;
            prev_char_hp <= 0; prev_char_aggro <= 0;
            prev_flip_h <= 0; prev_char_class <= 0;
            prev_boss_x <= 0; prev_boss_y <= 0; prev_boss_hp <= 0;
        end else if (current_state == IDLE && data_changed) begin
            prev_char_x <= char_x; prev_char_y <= char_y;
            prev_char_hp <= char_hp; prev_char_aggro <= char_aggro;
            prev_flip_h <= flip_h; prev_char_class <= char_class;
            prev_boss_x <= boss_x; prev_boss_y <= boss_y; prev_boss_hp <= boss_hp;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            send_step <= 0;
            uart_data <= 0;
            uart_wr <= 0;
        end else begin
            current_state <= next_state;
            uart_wr <= 0;

            if (current_state == SENDING) begin
                if (tx_ready && !tx_full) begin
                    uart_data <= send_array[send_step];
                    uart_wr <= 1;
                    send_step <= send_step + 1;
                end

                if (send_step > 14) begin
                    send_step <= 0;
                    current_state <= IDLE;
                end
            end
        end
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE:    if (data_changed) next_state = SENDING;
            SENDING: if (send_step > 14) next_state = IDLE;
        endcase
    end

endmodule
