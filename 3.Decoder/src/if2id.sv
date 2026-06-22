module if2id#(
	parameter AWidth = 32,
	parameter DWidth = 32)(
	input logic clk,
	input logic rst_n,
	input logic[AWidth-1:0] instradd_in,
	input logic[DWidth-1:0] instr_in,
	output logic[AWidth-1:0] instradd_out,
	output logic[DWidth-1:0] instr_out
);

always_ff@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
		instradd_out <= 'h0;
		instr_out <= 'h0;
		end
	else
		begin
		instradd_out <= instradd_out;
		instr_out <= instr_out;
		end
endmodule