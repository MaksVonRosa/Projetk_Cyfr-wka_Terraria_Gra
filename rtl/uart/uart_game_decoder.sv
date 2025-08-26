//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   uart_game_decoder
 Author:        Maksymilian Wiącek
 Last modified: 2025-08-26
 Description:  UART game data decoder for player 2 and boss information
 */
//////////////////////////////////////////////////////////////////////////////
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
    output logic [6:0]  boss_out_hp,
    output logic        player2_game_start,
    output logic        data_valid
);

    //------------------------------------------------------------------------------
    // local parameters
    //------------------------------------------------------------------------------
    typedef enum logic [3:0] {
        IDLE,
        P_X_L, P_X_H, P_Y_L, P_Y_H, P_H, P_A, P_F, P_T,
        B_H, G_S
    } state_t;

    //------------------------------------------------------------------------------
    // local variables
    //------------------------------------------------------------------------------
    state_t current_state, next_state;

    logic [11:0] temp_p_x, temp_p_y;
    logic [3:0]  temp_p_hp, temp_p_aggro;
    logic        temp_p_flip_h;
    logic [1:0]  temp_p_class;
    logic [6:0]  temp_b_hp;
    logic        temp_game_start;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            player_2_x <= 0; player_2_y <= 0; player_2_hp <= 0; player_2_aggro <= 0;
            player_2_flip_h <= 0; player_2_class <= 0; boss_out_hp <= 0;
            player2_game_start <= 0;
            data_valid <= 0;
            temp_p_x <= 0; temp_p_y <= 0; temp_p_hp <= 0; temp_p_aggro <= 0;
            temp_p_flip_h <= 0; temp_p_class <= 0; temp_b_hp <= 0; temp_game_start <= 0;
        end else begin
            current_state <= next_state;
            data_valid <= 0;

            if (rx_valid && uart_rd) begin
                case (current_state)
                    P_X_L: temp_p_x[7:0] <= uart_data;
                    P_X_H: temp_p_x[11:8] <= uart_data[3:0];
                    P_Y_L: temp_p_y[7:0] <= uart_data;
                    P_Y_H: temp_p_y[11:8] <= uart_data[3:0];
                    P_H:   temp_p_hp <= uart_data[3:0];
                    P_A:   temp_p_aggro <= uart_data[3:0];
                    P_F:   temp_p_flip_h <= uart_data[0];
                    P_T:   temp_p_class <= uart_data[1:0];
                    B_H:   temp_b_hp <= uart_data[6:0];
                    G_S:   temp_game_start <= uart_data[0];
                    default: ;
                endcase

                if (current_state == G_S) begin
                    player_2_x <= temp_p_x;
                    player_2_y <= temp_p_y;
                    player_2_hp <= temp_p_hp;
                    player_2_aggro <= temp_p_aggro;
                    player_2_flip_h <= temp_p_flip_h;
                    player_2_class <= temp_p_class;
                    boss_out_hp <= temp_b_hp;
                    player2_game_start <= temp_game_start;
                    data_valid <= 1;
                end
            end
        end
    end

    always_comb begin
        next_state = current_state;
        if (rx_valid && uart_rd) begin
            case (current_state)
                IDLE:   if (uart_data=="D") next_state=P_X_L;
                P_X_L:  next_state=P_X_H;
                P_X_H:  next_state=P_Y_L;
                P_Y_L:  next_state=P_Y_H;
                P_Y_H:  next_state=P_H;
                P_H:    next_state=P_A;
                P_A:    next_state=P_F;
                P_F:    next_state=P_T;
                P_T:    next_state=B_H;
                B_H:    next_state=G_S;
                G_S:    next_state=IDLE;
                default: next_state=IDLE;
            endcase
        end
    end
endmodule