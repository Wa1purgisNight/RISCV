module if2id#(
	parameter AWidth = 32,
	parameter DWidth = 32)(
	input logic clk,
	input logic rst_n,
	input logic instr_flush,
	input logic[AWidth-1:0] instradd_in,
	input logic[DWidth-1:0] instr_in,
	output logic[AWidth-1:0] instradd_out,
	output logic[DWidth-1:0] instr_out

	
);

always_ff@(posedge clk or negedge rst_n)
	if(!rst_n)
		begin
		instradd_out <= '0;
		instr_out <= '0;
		end
	else if(instr_flush) begin
		instradd_out <= '0;
		instr_out <= 32'h00000013;  //nop
		end
	else begin
		instradd_out <= instradd_in;
		instr_out <= instr_in;
	end
endmodule