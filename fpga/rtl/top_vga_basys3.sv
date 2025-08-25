module top_vga_basys3 (
    input  wire clk,
    input  wire btnC,
    input  wire btnU,
    input  wire btnR,
    input  wire btnL,
    input  wire btnD,
    output wire Vsync,
    output wire Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire JA1,
    output wire tx,
    input  wire rx,
    output wire JA2, //TX
    input  wire JB1, //RX
    output logic [1:0] led,
    inout wire PS2Clk,
    inout wire PS2Data
);

    timeunit 1ns;
    timeprecision 1ps;

    wire clk_ss;
    wire locked;
    wire clk65MHz;
    wire clk100MHz;
    wire pclk_mirror;

    assign JA1 = pclk_mirror;

    clk_wiz_0_clk_wiz inst (
        .clk100MHz(clk100MHz),
        .clk65MHz(clk65MHz),
        .locked(locked),
        .clk_in1(clk)
    );

    ODDR pclk_oddr (
        .Q(pclk_mirror),
        .C(clk65MHz),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );
    wire [11:0] char_x;
    wire [11:0] char_y;
    wire [3:0] current_health;
    wire [3:0] char_aggro;
    wire [1:0] char_class;
    wire flip_h;
    wire [6:0] boss_hp;
    wire game_start;
    wire player2_game_start;
    wire [11:0] player_2_x;
    wire [11:0] player_2_y;
    wire [3:0]  player_2_hp;
    wire [3:0]  player_2_aggro;
    wire        player_2_flip_h;
    wire [1:0]  player_2_class;
    wire [6:0]  boss_out_hp;
    wire        uart_data_valid;

    logic [7:0] uart_data;
    logic       uart_wr;
    logic       tx_full;
    logic       rx_empty;
    logic [7:0] r_data;
    logic       uart_rd;

    top_vga u_top_vga (
        .clk(clk65MHz),
        .clk100MHz(clk100MHz),
        .rst(btnC),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .stepleft(btnL),
        .stepright(btnR),
        .stepjump(btnU),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
        .game_start(game_start),
        .player2_game_start(player2_game_start),
        .char_x(char_x),
        .char_y(char_y),
        .current_health(current_health),
        .char_aggro(char_aggro),
        .char_class(char_class),
        .flip_h(flip_h),
        .boss_hp(boss_hp),
        .player_2_x(player_2_x),
        .player_2_y(player_2_y),
        .player_2_hp(player_2_hp),
        .player_2_aggro(player_2_aggro),
        .player_2_flip_h(player_2_flip_h),
        .player_2_class(player_2_class),
        .boss_out_hp(boss_out_hp),
        .player_2_data_valid(uart_data_valid)
    );

    uart_game_encoder u_uart_encoder (
        .clk(clk65MHz),
        .rst(btnC),
        .game_start(game_start),
        .char_x(char_x),
        .char_y(char_y),
        .char_hp(current_health),
        .char_aggro(char_aggro),
        .char_class(char_class),
        .flip_h(flip_h),
        .boss_hp(boss_hp),
        .tx_ready(!tx_full),
        .tx_full(tx_full),
        .uart_data(uart_data),
        .uart_wr(uart_wr)
    );
    uart #(
        .DBIT(8),
        .SB_TICK(16),
        .DVSR(35),
        .DVSR_BIT(6),
        .FIFO_W(6)
    ) uart_unit (
        .clk(clk65MHz),
        .reset(btnC),
        .wr_uart(uart_wr),
        .w_data(uart_data),
        .tx_full(tx_full),
        .tx(JA2),
        .rx(JB1),
        .rd_uart(uart_rd),
        .r_data(r_data),
        .rx_empty(rx_empty)
    );


    uart_game_decoder u_uart_decoder (
        .clk(clk65MHz),
        .rst(btnC),
        .uart_data(r_data),
        .uart_rd(uart_rd),
        .rx_valid(!rx_empty),
        .player_2_x(player_2_x),
        .player_2_y(player_2_y),
        .player_2_hp(player_2_hp),
        .player_2_aggro(player_2_aggro),
        .player_2_flip_h(player_2_flip_h),
        .player_2_class(player_2_class),
        .player2_game_start(player2_game_start),
        .boss_out_hp(boss_out_hp),
        .data_valid(uart_data_valid)
    );

    assign uart_rd = !rx_empty;

    assign led[0] = !tx_full;

endmodule