module mem_ram #(
	parameter	AW = 32,
	parameter	DW = 32	
	)( 
	input	logic		clk,
	input	logic		rst_n,
	input	logic		wr_en,
	input	logic[AW-1:0]	wr_addr,
	input	logic[DW-1:0]	wr_data,
	input	logic[AW-1:0]	rd_addr,
  	output	logic[DW-1:0]	rd_data									   	  
);  

function integer clogb2 (input integer bit_depth);
	begin     
  	for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
   	 bit_depth = bit_depth >> 1;
  end
endfunction

localparam	RATIO =	DW/8;
localparam	EX = clogb2(RATIO)-1;
logic [DW-1:0] 	ram_mem[0:4096-1];

always_ff @(posedge clk)
	if(wr_en)
		ram_mem[wr_addr[AW-1:EX]] <= wr_data;   //[31:2]
		 
always_comb	begin
	rd_data = ram_mem[rd_addr[AW-1:EX]];
end
		
endmodule