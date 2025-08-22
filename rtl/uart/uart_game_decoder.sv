module uart_game_decoder #(
    parameter DATA_WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0] uart_data,
    input  logic uart_rd,
    input  logic rx_valid,
    output logic [11:0] player_2_x,
    output logic [11:0] player_2_y,
    output logic [3:0]  player_2_hp,
    output logic [3:0]  player_2_aggro,
    output logic        player_2_flip_h,
    output logic [1:0]  player_2_class,
    output logic [11:0] boss_out_x,
    output logic [11:0] boss_out_y,
    output logic [6:0]  boss_out_hp,
    output logic        data_valid
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        READ_CX = 3'b001,
        READ_CY = 3'b010,
        READ_H = 3'b011,
        READ_A = 3'b100,
        READ_F = 3'b101,
        READ_T = 3'b110,
        READ_BOSS = 3'b111
    } state_t;

    state_t current_state, next_state;
    logic [7:0] received_data;
    logic [3:0] digit_counter;
    logic [11:0] temp_x, temp_y;
    logic [3:0] temp_hp;
    logic [3:0] temp_aggro;
    logic temp_flip_h;
    logic [1:0] temp_class;
    logic [11:0] temp_boss_x, temp_boss_y;
    logic [6:0] temp_boss_hp;

    function [3:0] from_ascii(input [7:0] ascii_char);
        if (ascii_char >= 8'h30 && ascii_char <= 8'h39) begin
            from_ascii = ascii_char - 8'h30;
        end else begin
            from_ascii = 4'b0;
        end
    endfunction

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            player_2_x <= 0;
            player_2_y <= 0;
            player_2_hp <= 0;
            player_2_aggro <= 0;
            player_2_flip_h <= 0;
            player_2_class <= 0;
            boss_out_x <= 0;
            boss_out_y <= 0;
            boss_out_hp <= 0;
            data_valid <= 0;
            digit_counter <= 0;
            temp_x <= 0;
            temp_y <= 0;
            temp_hp <= 0;
            temp_aggro <= 0;
            temp_flip_h <= 0;
            temp_class <= 0;
            temp_boss_x <= 0;
            temp_boss_y <= 0;
            temp_boss_hp <= 0;
        end else begin
            current_state <= next_state;
            data_valid <= 0;

            if (rx_valid && uart_rd) begin
                received_data <= uart_data;

                case (current_state)
                    IDLE: begin
                        if (uart_data == "C") begin
                            digit_counter <= 0;
                            temp_x <= 0;
                            temp_y <= 0;
                        end
                    end

                    READ_CX: begin
                        if (uart_data >= 8'h30 && uart_data <= 8'h39) begin
                            case (digit_counter)
                                0: temp_x[11:8] <= from_ascii(uart_data);
                                1: temp_x[7:4] <= from_ascii(uart_data);
                                2: temp_x[3:0] <= from_ascii(uart_data);
                            endcase
                            digit_counter <= digit_counter + 1;
                        end
                    end

                    READ_CY: begin
                        if (uart_data >= 8'h30 && uart_data <= 8'h39) begin
                            case (digit_counter)
                                0: temp_y[11:8] <= from_ascii(uart_data);
                                1: temp_y[7:4] <= from_ascii(uart_data);
                                2: temp_y[3:0] <= from_ascii(uart_data);
                            endcase
                            digit_counter <= digit_counter + 1;
                        end
                    end

                    READ_H: begin
                        if (uart_data >= 8'h30 && uart_data <= 8'h39) begin
                            temp_hp <= from_ascii(uart_data);
                        end
                    end

                    READ_A: begin
                        if (uart_data >= 8'h30 && uart_data <= 8'h39) begin
                            temp_aggro <= from_ascii(uart_data);
                        end
                    end

                    READ_F: begin
                        if (uart_data == "1") begin
                            temp_flip_h <= 1;
                        end else if (uart_data == "0") begin
                            temp_flip_h <= 0;
                        end
                    end

                    READ_T: begin
                        if (uart_data >= 8'h30 && uart_data <= 8'h39) begin
                            temp_class <= from_ascii(uart_data)[1:0];
                        end
                    end

                    READ_BOSS: begin
                        if (uart_data == "B") begin
                            digit_counter <= 0;
                        end else if (uart_data >= 8'h30 && uart_data <= 8'h39) begin
                            // Boss X
                            if (digit_counter < 3) begin
                                case (digit_counter)
                                    0: temp_boss_x[11:8] <= from_ascii(uart_data);
                                    1: temp_boss_x[7:4] <= from_ascii(uart_data);
                                    2: temp_boss_x[3:0] <= from_ascii(uart_data);
                                endcase
                                digit_counter <= digit_counter + 1;
                            end
                            // Boss Y
                            else if (digit_counter >= 4 && digit_counter < 7) begin
                                case (digit_counter - 4)
                                    0: temp_boss_y[11:8] <= from_ascii(uart_data);
                                    1: temp_boss_y[7:4] <= from_ascii(uart_data);
                                    2: temp_boss_y[3:0] <= from_ascii(uart_data);
                                endcase
                                digit_counter <= digit_counter + 1;
                            end
                            // Boss HP
                            else if (digit_counter >= 8 && digit_counter < 10) begin
                                case (digit_counter - 8)
                                    0: temp_boss_hp[6:4] <= from_ascii(uart_data);
                                    1: temp_boss_hp[3:0] <= from_ascii(uart_data);
                                endcase
                                digit_counter <= digit_counter + 1;
                            end
                        end
                    end
                endcase

                if (uart_data == 8'h0A) begin
                    player_2_x <= temp_x;
                    player_2_y <= temp_y;
                    player_2_hp <= temp_hp;
                    player_2_aggro <= temp_aggro;
                    player_2_flip_h <= temp_flip_h;
                    player_2_class <= temp_class;
                    boss_out_x <= temp_boss_x;
                    boss_out_y <= temp_boss_y;
                    boss_out_hp <= temp_boss_hp;
                    data_valid <= 1;
                end
            end
        end
    end

    always_comb begin
        next_state = current_state;
        
        if (rx_valid && uart_rd) begin
            case (current_state)
                IDLE: begin
                    if (uart_data == "C") next_state = READ_CX;
                end
                
                READ_CX: begin
                    if (uart_data == ",") next_state = READ_CY;
                end
                
                READ_CY: begin
                    if (uart_data == "|") next_state = READ_H;
                end
                
                READ_H: begin
                    if (uart_data == "|") next_state = READ_A;
                end
                
                READ_A: begin
                    if (uart_data == "|") next_state = READ_F;
                end
                
                READ_F: begin
                    if (uart_data == "|") next_state = READ_T;
                end
                
                READ_T: begin
                    if (uart_data == "|") next_state = READ_BOSS;
                end
                
                READ_BOSS: begin
                    if (uart_data == 8'h0D) next_state = IDLE; // CR
                end
                
                default: next_state = IDLE;
            endcase
        end
    end

endmodule