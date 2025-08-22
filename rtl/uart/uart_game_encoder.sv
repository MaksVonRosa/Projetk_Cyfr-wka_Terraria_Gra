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
    input  logic [3:0]  char_aggro,
    input  logic        flip_h,
    input  logic [1:0]  char_class,
    input  logic tx_ready,
    input  logic tx_full,  
    output logic [DATA_WIDTH-1:0] uart_data,
    output logic uart_wr
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        PREPARE = 2'b01,
        SENDING = 2'b10
    } state_t;

    state_t current_state, next_state;

    logic [7:0] ascii_buffer [0:47];
    logic [5:0] buffer_index;
    logic [5:0] send_index;
    logic [23:0] send_timer;
    logic can_send;

    function [7:0] to_ascii_dec(input [3:0] value);
        to_ascii_dec = 8'h30 + value;
    endfunction

    logic [11:0] prev_char_x, prev_char_y;
    logic [3:0]  prev_char_hp;
    logic [6:0]  prev_boss_hp;
    logic [11:0] prev_boss_x, prev_boss_y;
    logic [3:0]  prev_char_aggro;
    logic        prev_flip_h;
    logic [1:0]  prev_char_class;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            send_timer <= 0;
            can_send <= 1;
        end else begin
            send_timer <= send_timer + 1;
            if (send_timer == 6_500_000) begin
                can_send <= 1;
                send_timer <= 0;
            end else if (current_state == SENDING && send_index > buffer_index) begin
                can_send <= 0;
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_char_x <= '0; prev_char_y <= '0;
            prev_char_hp <= '0; prev_boss_hp <= '0;
            prev_boss_x <= '0; prev_boss_y <= '0;
            prev_char_aggro <= '0;
            prev_flip_h <= '0;
            prev_char_class <= '0;
        end else begin
            prev_char_x <= char_x; prev_char_y <= char_y;
            prev_char_hp <= char_hp; prev_boss_hp <= boss_hp;
            prev_boss_x <= boss_x; prev_boss_y <= boss_y;
            prev_char_aggro <= char_aggro;
            prev_flip_h <= flip_h;
            prev_char_class <= char_class;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            buffer_index <= 0;
            send_index <= 0;
            uart_wr <= 0;
            uart_data <= 0;
            
            for (int i = 0; i < 48; i++) begin
                ascii_buffer[i] <= 0;
            end
        end else begin
            current_state <= next_state;
            uart_wr <= 0;
            
            case (current_state)
                IDLE: begin
                end
                
                PREPARE: begin
                    ascii_buffer[0]  <= "C"; 
                    ascii_buffer[1]  <= "X"; 
                    ascii_buffer[2]  <= ":";
                    ascii_buffer[3]  <= to_ascii_dec(char_x[11:8]);
                    ascii_buffer[4]  <= to_ascii_dec(char_x[7:4]);
                    ascii_buffer[5]  <= to_ascii_dec(char_x[3:0]);
                    ascii_buffer[6]  <= ","; 
                    ascii_buffer[7]  <= "Y"; 
                    ascii_buffer[8]  <= ":";
                    ascii_buffer[9]  <= to_ascii_dec(char_y[11:8]);
                    ascii_buffer[10] <= to_ascii_dec(char_y[7:4]);
                    ascii_buffer[11] <= to_ascii_dec(char_y[3:0]);
                    ascii_buffer[12] <= "|"; 
                    ascii_buffer[13] <= "H"; 
                    ascii_buffer[14] <= ":";
                    ascii_buffer[15] <= to_ascii_dec(char_hp[3:0]);
                    ascii_buffer[16] <= "|"; 
                    ascii_buffer[17] <= "A";
                    ascii_buffer[18] <= ":"; 
                    ascii_buffer[19] <= to_ascii_dec(char_aggro[3:0]);
                    ascii_buffer[20] <= "|"; 
                    ascii_buffer[21] <= "F";
                    ascii_buffer[22] <= ":";
                    ascii_buffer[23] <= (flip_h) ? "1" : "0";
                    ascii_buffer[24] <= "|";
                    ascii_buffer[25] <= "T";
                    ascii_buffer[26] <= ":";
                    ascii_buffer[27] <= to_ascii_dec({2'b0, char_class});
                    ascii_buffer[28] <= "|"; 
                    ascii_buffer[29] <= "B"; 
                    ascii_buffer[30] <= "X"; 
                    ascii_buffer[31] <= ":";
                    ascii_buffer[32] <= to_ascii_dec(boss_x[11:8]);
                    ascii_buffer[33] <= to_ascii_dec(boss_x[7:4]);
                    ascii_buffer[34] <= to_ascii_dec(boss_x[3:0]);
                    ascii_buffer[35] <= ","; 
                    ascii_buffer[36] <= "Y"; 
                    ascii_buffer[37] <= ":";
                    ascii_buffer[38] <= to_ascii_dec(boss_y[11:8]);
                    ascii_buffer[39] <= to_ascii_dec(boss_y[7:4]);
                    ascii_buffer[40] <= to_ascii_dec(boss_y[3:0]);
                    ascii_buffer[41] <= "|"; 
                    ascii_buffer[42] <= "B"; 
                    ascii_buffer[43] <= "H"; 
                    ascii_buffer[44] <= ":";
                    ascii_buffer[45] <= to_ascii_dec(boss_hp[6:4]);
                    ascii_buffer[46] <= to_ascii_dec(boss_hp[3:0]); 
                    ascii_buffer[47] <= 8'h0D;
                    ascii_buffer[48] <= 8'h0A;
                    
                    buffer_index <= 48;
                    send_index <= 0;
                end
                
                SENDING: begin
                    if (tx_ready && !tx_full) begin
                        if (send_index <= buffer_index) begin
                            uart_data <= ascii_buffer[send_index];
                            uart_wr <= 1'b1;
                            send_index <= send_index + 1;
                        end
                    end
                end
            endcase
        end
    end

    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (can_send && (char_x != prev_char_x || char_y != prev_char_y || 
                     char_hp != prev_char_hp || boss_hp != prev_boss_hp ||
                     boss_x != prev_boss_x || boss_y != prev_boss_y ||
                     char_aggro != prev_char_aggro ||
                     flip_h != prev_flip_h ||
                     char_class != prev_char_class)) begin
                    next_state = PREPARE;
                end
            end
            
            PREPARE: begin
                next_state = SENDING;
            end
            
            SENDING: begin
                if (send_index > buffer_index) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

endmodule