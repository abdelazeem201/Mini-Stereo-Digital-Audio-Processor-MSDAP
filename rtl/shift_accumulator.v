//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig UNiversity
// Engineer: 
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: shift_acc    
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
module shift_accumulator(
                      input wire [39:0] in_bk,
                      input wire shift_en,
                      input wire load, clear, sclk,
                      output [39:0] out_bk );
reg [39:0] shift_reg;
	
always @(negedge sclk)
   begin
     if (clear)
	 shift_reg = 40'd0;
     if (load && shift_en)
	 shift_reg = {in_bk[39], in_bk[39:1]};
     else if (load && !shift_en)
	 shift_reg = in_bk;
     else
	 shift_reg = shift_reg;
   end

assign out_bk = shift_reg;
			
endmodule
