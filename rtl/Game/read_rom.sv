module read_rom #(
    parameter ROM_WIDTH  = 12,
    parameter ROM_DEPTH  = 2048,
    parameter FILE_PATH  = ""
)(
    input  logic [15:0] addr,
    output logic [ROM_WIDTH-1:0] data
);
    logic [ROM_WIDTH-1:0] rom_mem [0:ROM_DEPTH-1];

    initial begin
        if (FILE_PATH != "") begin
            $readmemh(FILE_PATH, rom_mem);
        end
    end

    assign data = rom_mem[addr];
endmodule
