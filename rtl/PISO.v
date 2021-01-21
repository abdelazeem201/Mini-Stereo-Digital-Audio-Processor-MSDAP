//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University 
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/12/2021 
// Design Name: MSDAP
// Module Name: PISO    
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
module PISO (
            input wire Sclk, Clear, p2s_en, Frame,
            input wire [39:0] Shift_done,
            output reg SerialOut, OutReady );

reg [5:0] count_bit; 
reg ready_out, frame_flag;
reg [39:0] register_piso;

always @(posedge Sclk)
    begin
      if(Clear == 1'b1)
	begin
	  count_bit = 6'd40;
	  register_piso = 40'd0;
	  ready_out = 1'b0;
	  frame_flag = 1'b0;
	  OutReady = 1'b0;
	  SerialOut = 1'b0;
	end
      else if (p2s_en == 1'b1)
	begin
	  register_piso = Shift_done;
	  ready_out = 1'b1;
	end
      else if (Frame == 1'b1 && ready_out == 1'b1 && frame_flag == 1'b0)
	begin
	  count_bit = count_bit - 1'b1;
	  SerialOut = register_piso [count_bit];
	  frame_flag = 1'b1;
	  ready_out = 1'b0;
	  OutReady = 1'b1;
	end
      else if (frame_flag == 1'b1)
	begin
	  count_bit = count_bit - 1'b1;
          SerialOut = register_piso [count_bit];
	  OutReady = 1'b1;
	    if (count_bit == 6'd0)
		frame_flag = 1'b0;
	end
	    else
	      begin
		count_bit = 6'd40;
		SerialOut = 1'b0;
		OutReady = 1'b0;
	      end
       end
endmodule
