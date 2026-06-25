module id2ex #(
	parameter AWidth = 32,
	parameter DWidth = 32)(
	input logic clk,
	input logic rst_n,
	input logic instr_flush,

	input logic[AWidth-1:0] instr_addr_in,
	input logic[DWidth-1:0] instr_in,
	input logic[DWidth-1:0] op1_in,
	input logic[DWidth-1:0] op2_in,

	output logic[AWidth-1:0] instr_addr_out,
	output logic[DWidth-1:0] instr_out,
	output logic[DWidth-1:0] op1_out,
	output logic[DWidth-1:0] op2_out
	);

always_ff@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
	instr_addr_out <= '0;
	instr_out <= '0;
	op1_out <= '0;
	op2_out <= '0;
	end
	else if(instr_flush) begin
	instr_addr_out <= '0;
	instr_out <= 32'h00000013; //nop
	op1_out <= '0;
	op2_out <= '0;
	end
	else begin
	instr_addr_out <= instr_addr_in;
	instr_out <= instr_in;
	op1_out <= op1_in;
	op2_out <= op2_in;
	end


end


endmodule