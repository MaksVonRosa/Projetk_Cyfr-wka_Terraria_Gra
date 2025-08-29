//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   tick_gen
 Author:        Damian Szczepaniak
 Last modified: 2025-08-28
 Description:   Generating 60Hz frame tick module for animations 
 */
//////////////////////////////////////////////////////////////////////////////
module tick_gen(
    input logic clk,
    input logic rst,
    output logic frame_tick

);
    logic [20:0] tick_count;

    localparam integer FRAME_TICKS = 45_000_000 / 60;

    always_ff @(posedge clk) begin
        if (rst) begin
            tick_count <= 0;
            frame_tick <= 0;
        end
        else begin if (tick_count == FRAME_TICKS - 1) begin
            tick_count <= 0;
            frame_tick <= 1;
        end else begin
            tick_count <= tick_count + 1;
            frame_tick <= 0;
        end
    end
end


endmodule