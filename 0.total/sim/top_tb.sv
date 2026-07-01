`timescale 1ns/1ps
module top_tb;

`define AWidth 32
`define DWidth 32
`define FILE "instr_data.dat"
logic clk, rst;


initial begin
	clk = 1'b0;
	@(negedge rst)
	@(posedge rst)
	repeat(50) #5 clk = ~clk;
	$finish;
end

initial begin
	rst = 1'b1;
	#10
	rst = '0;
	#10
	rst = 1'b1;
end

	RiscV#(
	.AWidth(`AWidth),
	.DWidth(`DWidth),
	.FILE(`FILE)
	)RiscV_inst(
	.clk(clk),
	.rst(rst));

endmodule