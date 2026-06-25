module registerFile #(
	parameter AWidth = 32,
	parameter DWidth = 32)(
	input logic clk,
	input logic rst_n,
	input logic[$clog2(AWidth)-1:0] reg1_addr,
	input logic[$clog2(AWidth)-1:0] reg2_addr,

	output logic[DWidth-1:0] reg1,
	output logic[DWidth-1:0] reg2,

	input logic wr_en,
	input logic[$clog2(AWidth)-1:0] wr_addr,
	input logic[DWidth-1:0] wr_data
);

logic[DWidth-1:0] Register[AWidth-1:0];

always_comb begin
	if(!rst_n)
		reg1 = 'h0;
	else if (reg1_addr == 'h0)
		reg1 = 'h0;
	else if (wr_en && (reg1_addr == wr_addr)) //if in next cycle rs1 need the written back value 
		reg1 = Register[wr_addr];
	else 
		reg1 = Register[reg1_addr];
end

always_comb begin
	if(!rst_n)
		reg2 = 'h0;
	else if (reg2_addr == 'h0)
		reg2 = 'h0;
	else if (wr_en && (reg2_addr == wr_addr)) 
		reg2 = Register[wr_addr];
	else 
		reg2 = Register[reg2_addr];
end

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		foreach(Register[i]) Register[i] <= '0;

	else if(wr_en && (wr_addr != 32'h0))
		Register[wr_addr] <= wr_data;
end

endmodule