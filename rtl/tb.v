//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: Test_benche   
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
`timescale 1ns / 1ps

module tb;

	// Inputs
	reg Dclk;
	reg Sclk;
	reg Reset_n;
	reg Frame;
	reg Start;
	reg InputL;
	reg InputR;

	// Outputs
	wire InReady_reg;
	wire OutReady_reg;
	wire OutputL_reg;
	wire OutputR_reg;
	
	wire InReady, OutReady;
	integer count=0;

	top uut_reg (
		.Dclk(Dclk), 
		.Sclk(Sclk), 
		.Reset_n(Reset_n), 
		.Frame(Frame), 
		.Start(Start), 
		.InputL(InputL), 
		.InputR(InputR), 
		.InReady(InReady_reg), 
		.OutReady(OutReady_reg), 
		.OutputL(OutputL_reg), 
		.OutputR(OutputR_reg) );

	reg [15:0] data [0:15055];
	parameter Dclk_Time = 651; 
	parameter Sclk_Time = 18; 
	
	always
	begin
		#(Dclk_Time) Dclk = ~Dclk;
	end
	
	always
	begin
		#(Sclk_Time) Sclk = ~Sclk;
	end
	
	integer l = 39, m = 0, n = 15, mv;
	reg [39:0] writeL = 40'd0, writeR = 40'd0;
	reg flag_reset = 1'b0;
	
	reg OutputL, OutputR;
	assign OutReady = OutReady_reg;
	assign InReady = InReady_reg;

	
	initial begin
		mv = $fopen ("output2.txt", "w+");
	end
	
	initial begin
		Dclk = 1;
		Sclk = 1;
		Frame = 0;
		InputL = 0;
		InputR = 0;
		Reset_n = 1;
		
		$readmemh ("data2.in", data);
    	Start = 1'b1;
		#2; Start = 1'b0;
		
		if (count==6394)
		$finish;
	end
	
	always @(posedge Dclk)
	begin
		if ((((m == 9458) || (m == 13058)) && flag_reset == 1'b0))
		begin
			Reset_n = 1'b0;
			flag_reset = 1'b1;
		end
		else if (InReady || flag_reset)
		begin
			if (m < 15056)
			begin
				Reset_n = 1'b1;
				if (n == 15 )
					Frame = 1'b1;
				else
					Frame = 1'b0;
				if (n >= 0)
				begin
					InputL = data[m][n];
					InputR = data[m+1][n];
					n = n - 1;
				end
				if (n == -1)
				begin
					n = 15;
					m = m + 2;
					if (flag_reset)
						flag_reset = 1'b0;
				end
			end
		end
	end
	
	always @(negedge Sclk)
	begin
		if (OutReady)
		begin
			writeL[l] = OutputL_reg ;
			writeR[l] = OutputR_reg ;
			OutputL = OutputL_reg ;
			OutputR = OutputR_reg;
			l = l - 1;
			if (l < 0 && count < 6395 )
			begin
				if(count!=3798 && count!= 5397)
				$fwrite (mv, "   %h      %h\n", writeL, writeR);
				count=count+1;
				l = 39;
			
			end
		end
	end

endmodule 
