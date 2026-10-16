module alu #(
	parameter AWidth = 32,
	parameter DWidth = 32)(
	input logic[AWidth-1:0] instr_addr_in, //PC
	input logic[DWidth-1:0] instr_in,
	input logic[DWidth-1:0] op1_in,
	input logic[DWidth-1:0] op2_in,
	input logic[DWidth-1:0] rs2_data,

	output logic 			 wr_en,
	output logic[4:0] 		 wr_addr,
	output logic[DWidth-1:0] 	 wr_data,
	output logic			 jump_en, //flush
	output logic[AWidth-1:0]	 jump_addr,

  	//ram
  	output	logic	[AWidth-1:0]	rd_ram_addr,
  	output	logic			wr_ram_en,
  	output	logic	[AWidth-1:0]	wr_ram_addr,
  	output	logic	[DWidth-1:0]	wr_ram_data
	);

logic[6:0] opcode;
logic[4:0] rd;
logic[2:0] funct3;
logic[4:0] rs1;
logic[4:0] rs2;
logic[6:0] funct7;
logic[DWidth-1:0] imm_b;
logic[DWidth-1:0] jump_imm;

assign opcode = instr_in[6:0];
assign rd = instr_in[11:7];
assign funct3 = instr_in[14:12];
assign rs1 = instr_in[19:15];
assign rs2 = instr_in[24:20];
assign funct7 = instr_in[31:25];
assign imm_b = {{19{instr_in[31]}},
		instr_in[31],
		instr_in[7],
		instr_in[30:25],
		instr_in[11:8],
		1'b0};//B-type


assign jump_imm = (instr_addr_in + imm_b);

always_comb begin
    wr_data   = '0;
    wr_addr   = '0;
    wr_en     = '0;
    jump_en   = '0;
    jump_addr = '0;
    rd_ram_addr = '0;
    wr_ram_en = '0;
    wr_ram_addr = '0;
    wr_ram_data = '0;
	case(opcode)
        // R-type ALU
        	7'b0110011: begin
            		wr_addr = rd;
            		wr_en   = 1'b1;

			case (funct7)
				7'b0000000:begin
				case (funct3)
					3'b000: wr_data = op1_in + op2_in; // ADD
					3'b001: wr_data = op1_in << op2_in[4:0]; // SLL
					3'b010:	wr_data = ($signed(op1_in) < $signed(op2_in)) ? 32'd1 : 32'd0; // SLT
					3'b011: wr_data = (op1_in < op2_in) ? 32'd1 : 32'd0; // SLTU
					3'b100: wr_data = op1_in ^ op2_in; // XOR
					3'b101: wr_data = op1_in >> op2_in[4:0]; // SRL
					3'b110: wr_data = op1_in | op2_in; // OR
					3'b111: wr_data = op1_in & op2_in; // AND
					default: begin
            					wr_en   = '0;
						wr_addr = '0;
						wr_data = '0;
						end
				endcase
				end

					
				7'b0100000:begin
				case (funct3)
					3'b000: wr_data = op1_in - op2_in; // SUB
					3'b101: wr_data = $signed(op1_in) >>> op2_in[4:0]; // SRA
					default: begin
            					wr_en   = '0;
						wr_addr = '0;
						wr_data = '0;
						end
				endcase
				end

				default: begin
            				wr_en   = '0;
					wr_addr = '0;
					wr_data = '0;
				end
				
			endcase
        	end


		7'b0010011 : begin //I-type Instruction
			wr_addr = rd;
			wr_en = 1'b1;
			case(funct3)
				3'b000 :  wr_data = op1_in + op2_in;// ADDI
				3'b010: wr_data = ($signed(op1_in) < $signed(op2_in)) ? 32'd1 : 32'd0; // SLTI
				3'b011: wr_data = (op1_in < op2_in) ? 32'd1 : 32'd0; // SLTIU
				3'b100: wr_data = op1_in ^ op2_in; // XORI
				3'b110: wr_data = op1_in | op2_in; // ORI
				3'b111: wr_data = op1_in & op2_in; // ANDI
				3'b001: begin
					case(funct7)
						7'b0000000: wr_data = op1_in << op2_in[4:0]; // SLLI
						default: begin
							wr_data = '0;
							wr_en   = 1'b0;
							wr_addr = '0;
						end
					endcase
				end
				3'b101: begin
					case(funct7)
						7'b0000000: wr_data = op1_in >> op2_in[4:0]; // SRLI
						7'b0100000: wr_data = $signed(op1_in) >>> op2_in[4:0]; // SRAI
						default: begin
							wr_data = '0;
							wr_en   = 1'b0;
							wr_addr = '0;
						end
					endcase
				end
				default: begin
					wr_data = '0;
					wr_en   = 1'b0;
					wr_addr = '0;
				end
			endcase
			end


        	// LOAD
        	// op2_in = I-type immediate
        	// ALU only comput addr in mem?load/store operation done in MEM unit 
        	7'b0000011: begin
            		rd_ram_addr = op1_in + op2_in; // addr = rs1 + imm
    			wr_addr     = rd;
    			wr_en       = 1'b1;
        	end


        	// STORE
        	// op2_in = S-type immediate
        	7'b0100011: begin
            		wr_ram_en   = 1'b1;
            		wr_ram_addr = op1_in + op2_in; // addr = rs1 + imm
			wr_ram_data = rs2_data;
        	end


        	// BRANCH
        	// op2_in = rs2
        	7'b1100011: begin
		jump_addr = jump_imm; //PC + imm
            	case (funct3)
                	3'b000: begin
				jump_en = (op1_in == op2_in); // BEQ
				end
                	3'b001: begin 
				jump_en = (op1_in != op2_in); // BNE
				end
                	3'b100: begin
				jump_en = ($signed(op1_in) <  $signed(op2_in)); // BLT
				end
                	3'b101: begin 
				jump_en = ($signed(op1_in) >= $signed(op2_in)); // BGE
				end
                	3'b110: begin 
				jump_en = (op1_in <  op2_in); // BLTU
				end
                	3'b111: begin
				jump_en = (op1_in >= op2_in); // BGEU
				end
                	default: begin 
				jump_en = 1'b0;
				jump_addr = 'h0;
				end
            	endcase
        	end

        	// JAL
        	// op2_in = J-type immediate
        	7'b1101111: begin
            	wr_addr   = rd;
            	wr_en     = 1'b1;
            	wr_data   = instr_addr_in + 32'd4;
            	jump_en   = 1'b1;
            	jump_addr = instr_addr_in + op2_in;
        	end


        	// JALR
        	// op1_in = rs1
        	// op2_in = I-type immediate
        	7'b1100111: begin
		if(funct3 == 3'b000)begin
            		wr_addr   = rd;
            		wr_en     = 1'b1;
            		wr_data   = instr_addr_in + 32'd4;
            		jump_en   = 1'b1;
            		jump_addr = (op1_in + op2_in) & ~32'd1; //ISA:JALR clears the least-significant bit of the computed target address. For bit alignment
		end
		else begin
			wr_addr   = '0;
            		wr_en     = '0;
            		wr_data   = '0;
            		jump_en   = '0;
            		jump_addr = '0; 
		end
        	end

        	// LUI
        	// op2_in = U-type immediate
        	7'b0110111: begin
            	wr_addr = rd;
            	wr_en   = 1'b1;
            	wr_data = op2_in;
        	end


        	// AUIPC
        	// op2_in = U-type immediate
        	7'b0010111: begin
            	wr_addr = rd;
            	wr_en   = 1'b1;
            	wr_data = instr_addr_in + op2_in;
        	end
	endcase
end


endmodule