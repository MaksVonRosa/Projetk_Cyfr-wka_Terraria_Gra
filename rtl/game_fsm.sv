module game_fsm (
    input  logic clk,
    input  logic rst,
    input  logic game_start,
    input  logic back_to_menu,
    input logic [6:0]  boss_hp,
    input  logic [3:0] current_health,
    output logic [1:0] game_state
);
    typedef enum logic [1:0] {
        MENU       = 2'd0,
        GAME       = 2'd1,
        END_SCREEN = 2'd2
    } state_t;

    state_t state_next, state_reg;

    always_comb begin
        state_next = state_reg;
        case (state_reg)
            MENU:       if (game_start)      state_next = GAME;
            GAME:       if (current_health==0 || boss_hp==0) state_next = END_SCREEN;
            END_SCREEN: if (back_to_menu)    state_next = MENU;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state_reg <= MENU;
        else
            state_reg <= state_next;
    end

    assign game_state = state_reg;
endmodule
