module intrCtrl#(
	parameter AWidth = 32,
	parameter DWidth = 32
	)( 
	input	logic	clk,
	input	logic	rst_n,
	input	logic[AWidth-1:0]  	instr_addr_in,
	input	logic[DWidth-1:0]	instr_in,
	input	logic[DWidth-1:0]	mstatus_in,
	input	logic[DWidth-1:0]	mie_in,
	input	logic[DWidth-1:0]	mip_in,
	input	logic[DWidth-1:0]	mtvec_in,
	input	logic[DWidth-1:0]	mtval_in,
	input	logic[DWidth-1:0]	mepc_in,
	output	logic[DWidth-1:0]	mstatus_out,
	output  logic[DWidth-1:0]   	mcause_out,
	output	logic[DWidth-1:0]	mepc_out,
	output  logic           	int_en,
	output  logic[AWidth-1:0]	int_addr
);  

logic[6:0]	opcode;
logic		exception;
logic		illegal_instr;
logic		ecall;
logic		ebreak;
logic		mret;

logic [DW-1:0]  mcause;

assign	opcode = instr_in[6:0]			;
assign	ecall =	(instr_in == `INST_ECALL);
assign	ebreak = (instr_in == `INST_EBREAK);
assign	mret = (instr_in == `INST_MRET);
assign	exception = illegal_instr | ecall | ebreak;

always_comb begin
	case(opcode)
		`INST_TYPE_I,`INST_TYPE_R_M,`INST_TYPE_B,`INST_TYPE_S,`INST_TYPE_L,`INST_JALR,
		`INST_JAL,`INST_JALR,`INST_LUI,`INST_LUIPC,`INST_CSR:
			illegal_instr = 1'b0;
		default:
			illegal_instr = 1'b1;
	endcase
end

always_comb begin
  if(illegal_instr)
    mcause = 32'd2;
  else if(ecall)
    mcause = 32'd11;
  else if(ebreak)
    mcause = 32'd3;
  else 
    mcause = 32'd0;
end

always_ff @(posedge clk or negedge rst_n)
  if(!rst_n) begin
    mstatus_out <= 'h0;
    mepc_out    <= 'h0;
    mcause_out  <= 'h0;
  end   
  else if(exception) begin
    mstatus_out <= {mstatus_in[31:8],mstatus_in[3],mstatus_in[6:4],1'b0,mstatus_in[2:0]}; //reset [3]
    mepc_out    <= instr_addr_in;
    mcause_out  <= mcause;
  end
  else if(mret) begin
    mstatus_out <= {mstatus_in[31:4],mstatus_in[7],mstatus_in[2:0]};
  end

always_ff @(posedge clk or negedge rst_n)
  if(!rst_n) begin
    int_en   <= 1'b0;
    int_addr <= 'h0;
  end   
  else if(exception) begin
    int_en    <= 1'b1;
    int_addr  <= mtvec_in;
  end
  else if(mret) begin
    int_en    <= 1'b1;
    int_addr  <= mepc_in;
  end
  else begin
    int_en    <= 1'b0;
    int_addr  <= 'h0;
  end

endmodule