//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: Data_Memory   
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
module data_memory (
       input wire write_enable, read_enable, Sclk, in_flag,		
       input wire [15:0] in_data,
       input wire [7:0] datawrite, dataread,
       output wire [15:0] input_data,
       output reg flag_zero);

reg [15:0] datamem [0:255];
reg [11:0] count_zero;
	
always @(posedge Sclk)
	begin
	  if(write_enable == 1'b1)
	    datamem[datawrite] = in_data;
	  else
	    datamem[datawrite] = datamem[datawrite];
	end
always @(posedge in_flag)
	begin
	  if (in_data == 16'd0)
	    begin
	      count_zero = count_zero + 1'b1;
	   if (count_zero == 12'd800)
		 flag_zero = 1'b1;
	   else if (count_zero > 12'd800)
		begin
		count_zero = 12'd800;
		flag_zero = 1'b1;
	        end
	   end		
	   else if (in_data != 16'd0)
	       begin
		  count_zero = 12'd0;
		  flag_zero = 1'b0;
	       end
	 end

assign input_data = (read_enable) ? datamem[dataread] : 16'd0;

endmodule
