`timescale 1ns/1ps
module top_tb();

`define AWidth 32
`define DWidth 32
`define FILE "rv32ui-p-add.txt"

logic clk, rst, jump_en, instr_flush;
logic[`AWidth-1:0] jump_addr;
logic[`AWidth-1:0] InstrAddr;
logic[`DWidth-1:0] InstrCode;
logic[`AWidth-1:0] InstrAddr_if2id;
logic[`DWidth-1:0] InstrCode_if2id;


logic[$clog2(`AWidth)-1:0] reg1_addr;
logic[$clog2(`AWidth)-1:0] reg2_addr;
logic[`DWidth-1:0] rd_rs1_data;
logic[`DWidth-1:0] rd_rs2_data;
logic[`DWidth-1:0] op1_out;
logic[`DWidth-1:0] op2_out;

logic wr_en;
logic[$clog2(`AWidth)-1:0] wr_addr;
logic[`DWidth-1:0] wr_data;

logic[`AWidth-1:0] instr_addr_id2ex;
logic[`DWidth-1:0] instr_id2ex;
logic[`DWidth-1:0] op1_id2ex;
logic[`DWidth-1:0] op2_id2ex;

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

initial begin
	instr_flush = 1'b0;
	wr_en = 1'b1;
	wr_addr = '0;
	wr_data = '0;
end

assign jump_en = '0;
assign jump_addr = '0;

pc_counter  #(.AWidth(`AWidth))

	my_pc_counter(	
	.clk(clk),
	.rst_n(rst),
	.jump_en(jump_en),
	.jump_addr(jump_addr),
	.pc_pointer(InstrAddr)

);

InstructionRom #(
	.AWidth(`AWidth),
	.DWidth(`DWidth),
	.FILE(`FILE))

	my_InstructionRom(	
	.clk(clk),
	.rst_n(rst),
	.InstrAddr(InstrAddr),
	.InstrCode(InstrCode)
);

if2id#(
	.AWidth(`AWidth),
	.DWidth(`DWidth))
	my_if2id(
	.clk(clk),
	.rst_n(rst),
	.instr_flush(instr_flush),
	.instradd_in(InstrAddr),
	.instr_in(InstrCode),
	.instradd_out(InstrAddr_if2id),
	.instr_out(InstrCode_if2id)
);


registerFile #(
	.AWidth(`AWidth),
	.DWidth(`DWidth))
	my_registerFile(
	.clk(clk),
	.rst_n(rst),
	.reg1_addr(reg1_addr),
	.reg2_addr(reg2_addr),

	.reg1(rd_rs1_data),
	.reg2(rd_rs2_data),

	.wr_en(wr_en),
	.wr_addr(wr_addr),
	.wr_data(wr_data)
);

decoder#(
	.DWidth(`DWidth),
	.AWidth(`AWidth))

	my_decoder(
	.instr_in(InstrCode_if2id),
	.instradd_in(InstrAddr_if2id),
	.rd_rs1_addr(reg1_addr), //write to register file
	.rd_rs2_addr(reg2_addr),  

	.rd_rs1_data(rd_rs1_data), //read from register file
	.rd_rs2_data(rd_rs2_data),

	.op1_out(op1_out),
	.op2_out(op2_out)
);

id2ex #(
	.AWidth(`AWidth),
	.DWidth(`DWidth))
	my_id2ex(
	.clk(clk),
	.rst_n(rst),
	.instr_addr_in(InstrAddr_if2id),
	.instr_in(InstrCode_if2id),
	.instr_flush(instr_flush),
	.op1_in(op1_out),
	.op2_in(op2_out),

	.instr_addr_out(instr_addr_id2ex),
	.instr_out(instr_id2ex),
	.op1_out(op1_id2ex),
	.op2_out(op2_id2ex)
	);


endmodule