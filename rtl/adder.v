//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: adder    
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
module adder(
	input wire [39:0] a,
        input wire [39:0] b,
        input wire addsub,
	input wire adder_en,
        output wire [39:0] sum );


assign sum = (addsub == 1'b1) ? (b - a) :  (addsub == 1'b0) ? (b + a) : sum ;	

endmodule
