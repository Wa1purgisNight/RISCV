module alu #(
	parameter AWidth = 32,
	parameter DWidth = 32)(
	input logic[AWidth-1:0] instr_addr_in,
	input logic[DWidth-1:0] instr_in,
	input logic[DWidth-1:0] op1_in,
	input logic[DWidth-1:0] op2_in,

	output logic wr_en,
	output logic[$clog2(AWidth)-1:0] wr_addr,
	output logic[DWidth-1:0] wr_data
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

always_comb begin
	wr_data = '0;
	wr_addr = '0;
	wr_en = '0;

	case(opcode)
		7'b0010011 : begin
			case(funct3)
				3'b000 : begin
					wr_data = op1_in + op2_in;
					wr_addr = rd;
					wr_en = 1'b1;
					end
			endcase
			end

	endcase
end


endmodule