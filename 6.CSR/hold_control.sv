module hold_ctrl #(
	parameter	AW								= 32								,
	parameter	DW								=	32	
	)(
  input		logic								jump_en   					,
  input   logic [AW-1:0]			jump_addr				    ,
  input   logic               int_en              ,
  input   logic	[AW-1:0]			int_addr						,
  output  logic		            instr_hold					,
  output  logic [AW-1:0]			instr_addr  						
);  


always_comb begin
  if(int_en) begin
    instr_hold  = int_en    ;
    instr_addr  = int_addr  ;
  end
  else if(jump_en) begin
    instr_hold  = jump_en   ;
    instr_addr  = jump_addr ;
  end
  else begin
    instr_hold  = 1'b0      ;
    instr_addr  = 'h0       ;
  end
end
		
endmodule