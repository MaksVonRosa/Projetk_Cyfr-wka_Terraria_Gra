module uart_game_encoder #(
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    // Dane z gry
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    input  logic [3:0] char_hp,
    input  logic [6:0] boss_hp,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic on_ground,
    // UART
    input  logic tx_ready,             // np. !tx_full
    output logic [DATA_WIDTH-1:0] uart_data,
    output logic uart_wr
);

    typedef enum logic [2:0] {
        SEND_CHAR_X0,
        SEND_CHAR_X1,
        SEND_CHAR_Y0,
        SEND_CHAR_Y1,
        SEND_CHAR_HP,
        SEND_BOSS_HP,
        SEND_BOSS_X0,
        SEND_BOSS_X1,
        SEND_BOSS_Y0,
        SEND_BOSS_Y1,
        SEND_ON_GROUND
    } send_state_t;

    send_state_t state, next_state;

    logic [7:0] data_byte;

    // Rozdzielanie 12-bitowych pozycji na dwa bajty
    logic [7:0] char_x_low  = char_x[7:0];
    logic [7:0] char_x_high = {4'b0, char_x[11:8]};
    logic [7:0] char_y_low  = char_y[7:0];
    logic [7:0] char_y_high = {4'b0, char_y[11:8]};
    logic [7:0] boss_x_low  = boss_x[7:0];
    logic [7:0] boss_x_high = {4'b0, boss_x[11:8]};
    logic [7:0] boss_y_low  = boss_y[7:0];
    logic [7:0] boss_y_high = {4'b0, boss_y[11:8]};

    // FSM wysyłania
    always_ff @(posedge clk or posedge rst) begin
        if(rst)
            state <= SEND_CHAR_X0;
        else if(tx_ready) 
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        uart_wr = 0;
        case(state)
            SEND_CHAR_X0: begin data_byte = char_x_low; uart_wr = tx_ready; next_state = SEND_CHAR_X1; end
            SEND_CHAR_X1: begin data_byte = char_x_high; uart_wr = tx_ready; next_state = SEND_CHAR_Y0; end
            SEND_CHAR_Y0: begin data_byte = char_y_low; uart_wr = tx_ready; next_state = SEND_CHAR_Y1; end
            SEND_CHAR_Y1: begin data_byte = char_y_high; uart_wr = tx_ready; next_state = SEND_CHAR_HP; end
            SEND_CHAR_HP: begin data_byte = {4'b0, char_hp}; uart_wr = tx_ready; next_state = SEND_BOSS_HP; end
            SEND_BOSS_HP: begin data_byte = boss_hp; uart_wr = tx_ready; next_state = SEND_BOSS_X0; end
            SEND_BOSS_X0: begin data_byte = boss_x_low; uart_wr = tx_ready; next_state = SEND_BOSS_X1; end
            SEND_BOSS_X1: begin data_byte = boss_x_high; uart_wr = tx_ready; next_state = SEND_BOSS_Y0; end
            SEND_BOSS_Y0: begin data_byte = boss_y_low; uart_wr = tx_ready; next_state = SEND_BOSS_Y1; end
            SEND_BOSS_Y1: begin data_byte = boss_y_high; uart_wr = tx_ready; next_state = SEND_ON_GROUND; end
            SEND_ON_GROUND: begin data_byte = {7'b0, on_ground}; uart_wr = tx_ready; next_state = SEND_CHAR_X0; end
        endcase
    end

    assign uart_data = data_byte;

endmodule
