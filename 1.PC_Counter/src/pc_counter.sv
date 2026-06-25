module pc_counter 
	#(parameter AWidth = 32)
(	
	input	logic			clk,
	input	logic			rst_n,
	input	logic			jump_en,
	input	logic[AWidth-1:0]	jump_addr,
	output	logic[AWidth-1:0]	pc_pointer

);

always_ff@(posedge clk or negedge rst_n)
	if(!rst_n)
		pc_pointer <= 'h0;
	else if(jump_en)
		pc_pointer <= jump_addr;
	else
		pc_pointer <= pc_pointer + 'h4;
endmodule