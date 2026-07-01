module decoder#(
	parameter DWidth = 32,
	parameter AWidth = 32)(
	input logic[DWidth-1:0] instr_in,
	//input logic[AWidth-1:0] instradd_in,
	output logic[4:0] rd_rs1_addr, //write to register file
	output logic[4:0] rd_rs2_addr,  

	//wr_reg_addr

	input logic[DWidth-1:0] rd_rs1_data, //read from register file
	input logic[DWidth-1:0] rd_rs2_data,

	output logic[DWidth-1:0] op1_out,
	output logic[DWidth-1:0] op2_out,
	output logic[DWidth-1:0] rs2_data_out
);

logic[6:0] opcode;
logic[4:0] rd;
logic[2:0] funct3;
logic[4:0] rs1;
logic[4:0] rs2;
logic[6:0] funct7;
logic[DWidth-1:0] imm;


assign opcode = instr_in[6:0];
assign rd = instr_in[11:7];
assign funct3 = instr_in[14:12];
assign rs1 = instr_in[19:15];
assign rs2 = instr_in[24:20];
assign funct7 = instr_in[31:25];

always_comb begin //some problem in bit width
	case(opcode)
		7'b0010011,7'b0000011,7'b1100111,7'b1110011: imm = {{20{instr_in[31]}}, instr_in[31:20]};//I-type
		7'b0100011: imm = {{20{instr_in[31]}},instr_in[31:25],instr_in[11:7]};//S-type
		7'b1100011: imm = {{19{instr_in[31]}},instr_in[31],instr_in[7],instr_in[30:25],instr_in[11:8],1'b0};//B-type
		7'b0110111,7'b0010111: imm = {instr_in[31:12], 12'b0};//U-type
		7'b1101111: imm = {{11{instr_in[31]}},instr_in[31],instr_in[19:12],instr_in[20],instr_in[30:21],1'b0};//J-type  
		default: imm = '0;
	endcase
	
end


always_comb begin
	rd_rs1_addr = 5'b0;
    	rd_rs2_addr = 5'b0;
    	op1_out     = '0;
    	op2_out     = '0;
	rs2_data_out= '0;
    	case (opcode)
        	// R-type ALU
        	// ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
        	7'b0110011: begin
            	rd_rs1_addr = rs1;
            	rd_rs2_addr = rs2;

            	op1_out = rd_rs1_data;
            	op2_out = rd_rs2_data;
        	end

        	// I-type ALU
        	// ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        	7'b0010011: begin
            	rd_rs1_addr = rs1;
            	rd_rs2_addr = 5'b0;

            	op1_out = rd_rs1_data;
            	op2_out = imm;
        	end

        	// LOAD
        	// LB, LH, LW, LBU, LHU
        	// op1 = rs1, op2 = I-type imm
        	7'b0000011: begin
            	rd_rs1_addr = rs1;
            	rd_rs2_addr = 5'b0;

            	op1_out = rd_rs1_data;
            	op2_out = imm;
        	end


        	// STORE
        	// SB, SH, SW
        	// op1 = rs1, op2 = S-type imm
        	7'b0100011: begin
            	rd_rs1_addr = rs1;
            	rd_rs2_addr = rs2;

            	op1_out = rd_rs1_data;
            	op2_out = imm; 
		rs2_data_out = rd_rs2_data;
        	end

		// BRANCH
        	7'b1100011: begin
            	rd_rs1_addr = rs1;
            	rd_rs2_addr = rs2;

            	op1_out = rd_rs1_data;
            	op2_out = rd_rs2_data;
        	end


        	// JAL
        	// op2_out = J-type immediate
        	7'b1101111: begin
            	rd_rs1_addr = 5'b0;
            	rd_rs2_addr = 5'b0;

            	op1_out = '0;
            	op2_out = imm;
        	end


        	// JALR
        	// op1 = rs1, op2 = I-type imm
        	7'b1100111: begin
            	rd_rs1_addr = rs1;
            	rd_rs2_addr = 5'b0;

            	op1_out = rd_rs1_data;
            	op2_out = imm;
        	end


        	// LUI
        	// rd = U-type immediate
        	7'b0110111: begin
            	rd_rs1_addr = 5'b0;
            	rd_rs2_addr = 5'b0;

            	op1_out = '0;
            	op2_out = imm;
        	end


        	// AUIPC
        	// rd = PC + U-type immediate
        	// PC = instr_addr_in 
        	7'b0010111: begin
            	rd_rs1_addr = 5'b0;
            	rd_rs2_addr = 5'b0;

            	op1_out = '0;
            	op2_out = imm;
        	end


        	default: begin
            	rd_rs1_addr = 5'b0;
            	rd_rs2_addr = 5'b0;
            	op1_out     = '0;
            	op2_out     = '0;
        	end


	endcase
end

endmodule

