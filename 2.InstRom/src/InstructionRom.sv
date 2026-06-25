module InstructionRom #(
	parameter AWidth = 32,
	parameter DWidth = 32,
	parameter FILE = "rv32ui-p-addi.txt"	)(	
	input	logic			clk,
	input	logic			rst_n,
	input	logic[AWidth-1:0]	InstrAddr,
	output	logic[DWidth-1:0]	InstrCode
);

static string path = "./../test_data/";
static string full_path = {path,FILE};

initial begin
	$readmemh(full_path,rom_mem);
end

logic[AWidth-1:0]  rom_mem[7:0];

always_comb
	InstrCode = rom_mem[InstrAddr[AWidth-1:2]];

endmodule