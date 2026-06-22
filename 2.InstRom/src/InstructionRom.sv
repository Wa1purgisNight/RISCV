module InstructionRom #(
	parameter AWidth = 32,
	parameter DWidth = 32,
	parameter FILE = "rv32ui-p-addi.txt"	)(	
	input	logic			clk,
	input	logic			rst_n,
	input	logic[width-1:0]	InstrAddr,
	output	logic[Dwidth-1:0]	InstrCode
);

static string path = "../test_data/";
static string full_path = {path,FILE};

logic[Awidth-1:0]  rom_mem[4096:0];

always_comb
	InstrCode = rom_mem[InstrAddr[Awidth-1:2]];

endmodule