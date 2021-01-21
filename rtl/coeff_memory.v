//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: Coeff_memory   
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

module coeff_memory (
             input wire write_enable, read_enable, Sclk,
	     input wire [15:0] in_data,
             input wire [8:0] coeffwrite, coeffread,							
       	     output wire [15:0] data_coeff);

 reg [15:0] coeffmem [0:511];

always @(posedge Sclk)
   begin
      if(write_enable == 1'b1)
	coeffmem[coeffwrite] = in_data;
      else
	coeffmem[coeffwrite] = coeffmem[coeffwrite];		
      end

assign data_coeff = (read_enable) ? coeffmem[coeffread] : 16'd0;

endmodule
