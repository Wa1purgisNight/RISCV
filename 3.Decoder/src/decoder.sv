module decoder#(
	parameter DWidth = 32)(
	input logic[DWidth-1:0] instr_in,
	output logic[4:0] rd_rs1_addr, //write to register file
	output logic[4:0] rd_rs2_addr,
	output logic[4:0] wr_reg_addr,

	input logic[DWidth-1:0] rd_rs1_data, //read from register file
	input logic[DWidth-1:0] rd_rs2_data,

	output logic[DWidth-1:0] op1_out,
	output logic[DWidth-1:0] op2_out
);

logic[6:0] opcode;
logic[4:0] rd;
logic[2:0] funct3;
logic[4:0] rs1;
logic[4:0] rs2;
logic[6:0] funct7;
logic[11:0] imm_i;
logic[11:0] imm_s;
logic[11:0] imm_b;
logic[19:0] imm_u;
logic[19:0] imm_j;

assign opcode = instr_in[6:0];
assign rd = instr_in[11:7];
assign funct3 = instr_in[14:12];
assign rs1 = instr_in[19:15];
assign rs2 = instr_in[24:20];
assign funct7 = instr_in[31:25];
assign imm_i = instr_in[31:20];
assign imm_s = {instr_in[31:25],instr_in[11:7]};
assign imm_b = {instr_in[31],instr_in[7],instr_in[30:25],instr_in[11:8]};
assign imm_u = instr_in[31:12];
assign imm_j = {instr_in[31],instr_in[19:12],instr_in[20],instr_in[30:21]};


always_comb
	if((opcode == 7'b0010011) && (func3 == 3'b000))
		begin
		rd_rs1_addr = rs1;
		rd_rs2_addr = 5'b0;
		op1_out = rd_rs1_data;
		op2_out = {{20{imm_i[11]}},imm_i}; //Symbol Expansion
		wr_reg_addr = rd;
		end
	else
		begin
		rd_rs1_addr = 'h0;
		rd_rs2_addr = 'h0;
		op1_out = 'h0;
		op2_out = 'h0; 
		wr_reg_addr = 'h0;
		end
endmodule