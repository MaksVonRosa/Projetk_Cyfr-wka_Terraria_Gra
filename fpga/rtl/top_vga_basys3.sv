module top_vga_basys3 (
    input  wire clk,
    input  wire btnC,
    input  wire btnU,
    input  wire btnR,
    input  wire btnL,
    input  wire btnD,
    input  logic rx,                
    output logic tx,
    output wire Vsync,
    output wire Hsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire JA1,
    output logic [3:0] led,
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
    wire [6:0] boss_hp;
    wire [11:0] boss_x;
    wire [11:0] boss_y;
    wire on_ground;

    top_vga u_top_vga (
        .clk(clk65MHz),
        .clk100MHz(clk100MHz),
        .rst(btnC),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .stepleft(btnL),
        .stepright(btnR),
        .stepjump(btnU),
        .buttondown(btnD),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
        .char_x(char_x),
        .char_y(char_y),
        .current_health(current_health),
        .boss_hp(boss_hp),
        .boss_x(boss_x),
        .boss_y(boss_y),
        .on_ground(on_ground)
    );

    logic [7:0] uart_data;
    logic       uart_wr;
    logic       tx_full;
    logic       rx_empty;
    logic [7:0] r_data;
    
    // ZASTĄP CAŁY BLOK TESTOWY TYM:

// TEST: Bezpośrednie podłączenie przycisku do uart_wr
assign uart_wr = btnU;  // Użyj przycisku btnU do ręcznego wysyłania
assign uart_data = 8'hAA; // Stałe dane testowe

// Diody
assign led[0] = !tx_full;    // TX gotowy
assign led[1] = uart_wr;     // TX aktywny (btnU)
assign led[2] = !rx_empty;   // RX ma dane  
assign led[3] = clk65MHz;    // Clock żyje (szybkie miganie)

// UART z oryginalnymi parametrami
uart #(
    .DBIT(8),
    .SB_TICK(16),
    .DVSR(424),    // Powrót do oryginalnych parametrów
    .DVSR_BIT(7),
    .FIFO_W(8)
) uart_unit (
    .clk(clk65MHz),
    .reset(btnC),
    .wr_uart(uart_wr),
    .w_data(uart_data),
    .tx_full(tx_full),
    .tx(tx),
    .rx(1'b1),
    .rd_uart(1'b0),
    .r_data(r_data),
    .rx_empty(rx_empty)
);

endmodule