module uart_game_encoder #(
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic [11:0] char_x,
    input  logic [11:0] char_y,
    input  logic [3:0]  char_hp,
    input  logic [6:0]  boss_hp,
    input  logic [11:0] boss_x,
    input  logic [11:0] boss_y,
    input  logic on_ground,
    input  logic tx_ready,
    input  logic tx_full,  
    output logic [DATA_WIDTH-1:0] uart_data,
    output logic uart_wr
);

    // Definicje pakietów
    typedef enum logic [2:0] {
        HEADER_CHAR_POS = 3'b000,
        HEADER_CHAR_HP   = 3'b001,
        HEADER_BOSS_POS  = 3'b010,
        HEADER_BOSS_HP   = 3'b011,
        HEADER_STATUS    = 3'b100,
        HEADER_RESERVED  = 3'b101
    } packet_header_t;

    // Rejestry do przechowywania poprzednich wartości
    logic [11:0] prev_char_x, prev_char_y;
    logic [3:0]  prev_char_hp;
    logic [6:0]  prev_boss_hp;
    logic [11:0] prev_boss_x, prev_boss_y;
    logic        prev_on_ground;

    // Stan maszyny stanów
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        SEND_HEADER = 3'b001,
        SEND_DATA_1 = 3'b010,
        SEND_DATA_2 = 3'b011,
        SEND_DATA_3 = 3'b100,
        WAIT_TX     = 3'b101
    } state_t;

    state_t current_state, next_state;

    // Rejestry stanu
    logic [2:0] packet_counter;
    logic [2:0] current_packet_type;
    logic [23:0] packet_data;

    // Sygnały zmiany danych
    logic char_pos_changed, char_hp_changed, boss_pos_changed, boss_hp_changed, status_changed;

    // Detekcja zmian
    assign char_pos_changed = (char_x != prev_char_x) || (char_y != prev_char_y);
    assign char_hp_changed  = (char_hp != prev_char_hp);
    assign boss_pos_changed = (boss_x != prev_boss_x) || (boss_y != prev_boss_y);
    assign boss_hp_changed  = (boss_hp != prev_boss_hp);
    assign status_changed   = (on_ground != prev_on_ground);

    // Rejestracja poprzednich wartości
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_char_x <= '0;
            prev_char_y <= '0;
            prev_char_hp <= '0;
            prev_boss_hp <= '0;
            prev_boss_x <= '0;
            prev_boss_y <= '0;
            prev_on_ground <= '0;
        end else begin
            prev_char_x <= char_x;
            prev_char_y <= char_y;
            prev_char_hp <= char_hp;
            prev_boss_hp <= boss_hp;
            prev_boss_x <= boss_x;
            prev_boss_y <= boss_y;
            prev_on_ground <= on_ground;
        end
    end

    // Logika następnego stanu
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (tx_ready && !tx_full && (char_hp_changed || boss_hp_changed || 
                    char_pos_changed || boss_pos_changed || status_changed)) begin
                    next_state = SEND_HEADER;
                end
            end
            
            SEND_HEADER: begin
                next_state = SEND_DATA_1;
            end
            
            SEND_DATA_1: begin
                if (tx_ready && !tx_full) begin
                    next_state = SEND_DATA_2;
                end
            end
            
            SEND_DATA_2: begin
                if (tx_ready && !tx_full) begin
                    next_state = SEND_DATA_3;
                end
            end
            
            SEND_DATA_3: begin
                if (tx_ready && !tx_full) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Maszyna stanów główna
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            packet_counter <= '0;
            uart_wr <= 1'b0;
            uart_data <= '0;
            current_packet_type <= '0;
            packet_data <= '0;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                IDLE: begin
                    uart_wr <= 1'b0;
                    if (tx_ready && !tx_full) begin
                        // Priorytetyzacja pakietów
                        if (char_hp_changed) begin
                            current_packet_type <= HEADER_CHAR_HP;
                            packet_data <= {20'b0, char_hp};
                        end else if (boss_hp_changed) begin
                            current_packet_type <= HEADER_BOSS_HP;
                            packet_data <= {17'b0, boss_hp};
                        end else if (char_pos_changed) begin
                            current_packet_type <= HEADER_CHAR_POS;
                            packet_data <= {char_x, char_y};
                        end else if (boss_pos_changed) begin
                            current_packet_type <= HEADER_BOSS_POS;
                            packet_data <= {boss_x, boss_y};
                        end else if (status_changed) begin
                            current_packet_type <= HEADER_STATUS;
                            packet_data <= {23'b0, on_ground};
                        end
                    end
                end

                SEND_HEADER: begin
                    uart_data <= {1'b0, current_packet_type, 4'b0}; // Bit startowy + header
                    uart_wr <= 1'b1;
                    packet_counter <= 0;
                end

                SEND_DATA_1: begin
                    uart_wr <= 1'b0;
                    if (tx_ready && !tx_full) begin
                        uart_data <= packet_data[23:16];
                        uart_wr <= 1'b1;
                    end
                end

                SEND_DATA_2: begin
                    uart_wr <= 1'b0;
                    if (tx_ready && !tx_full) begin
                        uart_data <= packet_data[15:8];
                        uart_wr <= 1'b1;
                    end
                end

                SEND_DATA_3: begin
                    uart_wr <= 1'b0;
                    if (tx_ready && !tx_full) begin
                        uart_data <= packet_data[7:0];
                        uart_wr <= 1'b1;
                    end
                end
            endcase
        end
    end

endmodule