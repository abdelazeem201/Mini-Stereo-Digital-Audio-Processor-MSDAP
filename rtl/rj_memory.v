//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/12/2021 
// Design Name: MSDAP
// Module Name: rj_memory   
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
////////////////////////////////////////////////////////////////////////////////
module rj_memory (
              input  wire write_enable, read_enable, Sclk,
	      input wire [15:0] in_data,
              input wire [3:0] rjwrite, rjread,	          				              output wire [15:0] data_rj );

reg [15:0] rjmem [0:15];
always @(posedge Sclk)
   begin
     if(write_enable == 1'b1)
	  rjmem[rjwrite] = in_data;
     else
	  rjmem[rjwrite] = rjmem[rjwrite];		
   end


assign data_rj = (read_enable) ? rjmem[rjread] : 16'd0;

endmodule
