//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/10/2021 
// Design Name: MSDAP
// Module Name: main_Controller   
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


module main_controller (
       input wire Sclk, Dclk, Start, Reset_n, Frame, in_flag, flag_zeroL,                          flag_zeroR,	
       output reg [3:0] rjwrite,
       output reg [8:0] coeffwrite,
       output reg [7:0] datawrite,
       output reg rj_enable, coeff_enable, data_enable, Clear,
       output wire Frame_out, Dclk_out, Sclk_out,
       output reg work_enable, sleep_flag, InReady);
	
parameter [3:0] Start_ini = 4'd0, 
                Wait_rj = 4'd1, 
                Read_rj = 4'd2,
	        Wait_coeff = 4'd3, 
                Read_coeff = 4'd4, 
                Wait_input = 4'd5,
	        Working = 4'd6, 
                Reset = 4'd7, 
                Sleep = 4'd8;
   
reg [3:0] state_present, state_next;
reg [15:0] count;
reg [4:0] count_rj;
reg [9:0] count_coeff;
reg [7:0] count_data;
reg tk;
	
assign Frame_out = Frame;
assign Dclk_out = Dclk;
assign Sclk_out = Sclk;
	
always @(posedge Sclk or negedge Reset_n)		// Sequential block
     begin
	if (!Reset_n)
	  begin
	    if (state_present > 4'd4)
		state_present = Reset;
	    else
		state_present = state_next;
	  end
	else
	   state_present = state_next;
     end
	
always @(posedge Sclk or posedge Start)
     begin
	if (Start == 1'b1)
	    state_next = Start_ini;
	else
	  begin
	   case (state_present)
			Start_ini:	begin
							rjwrite = 4'd0;
							coeffwrite = 9'd0;
							datawrite = 8'd0;
							rj_enable = 1'b0;
							coeff_enable = 1'b0;
							data_enable = 1'b0;
							Clear = 1'b1;
							work_enable = 1'b0;
							InReady = 1'b0;
							sleep_flag = 1'b0;
							state_next = Wait_rj;
							count = 16'd0;
							count_rj = 4'd0;
							count_coeff = 9'd0;
							count_data = 8'd0;
						end
			
			Wait_rj:	begin
							rjwrite = 4'd0;
							coeffwrite = 9'd0;
							datawrite = 8'd0;
							rj_enable = 1'b0;
							coeff_enable = 1'b0;
							data_enable = 1'b0;
							Clear = 1'b0;
							work_enable = 1'b0;
							InReady = 1'b1;
							sleep_flag = 1'b0;
							count_rj = 4'd0;
							count_coeff = 9'd0;
							count_data = 8'd0;
							tk = 1'b0;
							if (Frame == 1'b1)
								state_next = Read_rj;
							else
								state_next = Wait_rj;
						end
						
			Read_rj:	begin
							coeffwrite = 9'd0;
							datawrite = 8'd0;
							coeff_enable = 1'b0;
							data_enable = 1'b0;
							Clear = 1'b0;
							work_enable = 1'b0;
							InReady = 1'b1;
							sleep_flag = 1'b0;
							count_coeff = 9'd0;
							count_data = 8'd0;
							if (in_flag == 1'b1 && tk == 1'b0)
							begin
								if (count_rj < 5'd16)
								begin
									rj_enable = 1'b1;
									rjwrite = count_rj;
									count_rj = count_rj + 1'b1;
									state_next = Read_rj;
									tk = 1'b1;
								end
								if (count_rj == 5'd16)
								begin
									state_next = Wait_coeff;
								end
								else
									state_next = Read_rj;
							end
							else if (in_flag == 1'b0)
							begin
								tk = 1'b0;
								rj_enable = 1'b0;
								rjwrite = rjwrite;
								state_next = Read_rj;
							end
							else
								state_next = Read_rj;
						end
			
			Wait_coeff: 
							begin
								rjwrite = 4'd0;
								coeffwrite = 9'd0;
								datawrite = 8'd0;
								rj_enable = 1'b0;
								coeff_enable = 1'b0;
								data_enable = 1'b0;
								Clear = 1'b0;
								work_enable = 1'b0;
								InReady = 1'b1;
								sleep_flag = 1'b0;
								count_coeff = 9'd0;
								count_data = 8'd0;
								if (Frame == 1'b1)
									state_next = Read_coeff;
								else
									state_next = Wait_coeff;
							end
						
			Read_coeff: begin
								rjwrite = 4'd0;
								datawrite = 8'd0;
								rj_enable = 1'b0;
								data_enable = 1'b0;
								Clear = 1'b0;
								work_enable = 1'b0;
								InReady = 1'b1;
								sleep_flag = 1'b0;
								count_data = 8'd0;
								if (in_flag == 1'b1 && tk == 1'b0)
								begin
									if (count_coeff < 10'h200)
									begin
										coeff_enable = 1'b1;
										coeffwrite = count_coeff;
										count_coeff = count_coeff + 1'b1;
										state_next = Read_coeff;
										tk = 1'b1;
									end
									if (count_coeff == 10'h200)
										state_next = Wait_input;
									else
										state_next = Read_coeff;
								end
								else if (in_flag == 1'b0)
								begin
									tk = 1'b0;
									coeff_enable = 1'b0;
									coeffwrite = coeffwrite;
									state_next = Read_coeff;
								end
								else
									state_next = Read_coeff;
							end

			Wait_input: begin
								rjwrite = 4'd0;
								coeffwrite = 9'd0;
								datawrite = 8'd0;
								rj_enable = 1'b0;
								coeff_enable = 1'b0;
								data_enable = 1'b0;
								Clear = 1'b0;
								work_enable = 1'b0;
								InReady = 1'b1;
								sleep_flag = 1'b0;
								count_data = 8'd0;
								if (Reset_n == 1'b0)
									state_next = Reset;
								else if (Frame == 1'b1)
									state_next = Working;
								else
									state_next = Wait_input;
							end
		
			Working:	begin
							rjwrite = 4'd0;
							coeffwrite = 9'd0;
							rj_enable = 1'b0;
							coeff_enable = 1'b0;
							Clear = 1'b0;
							InReady = 1'b1;
							sleep_flag = 1'b0;
							if (Reset_n == 1'b0)
							begin
								Clear = 1'b1;
								state_next = Reset;								
							end
							else if (in_flag == 1'b1 && tk == 1'b0)
							begin
								if (flag_zeroL && flag_zeroR)
								begin
									state_next = Sleep;
									sleep_flag = 1'b1;
								end
								else
								begin
									data_enable = 1'b1;
									datawrite = count_data;
									count_data = count_data + 1'b1;
									count = count + 1'b1;
									state_next = Working;
									work_enable = 1'b1;
									tk = 1'b1;
								end
							end
							else if (in_flag == 1'b0)
							begin
								tk = 1'b0;
								data_enable = 1'b0;
								datawrite = datawrite;
								work_enable = 1'b0;
								state_next = Working;
							end
							else
							begin
								data_enable = 1'b0;
								datawrite = datawrite;
								state_next = Working;
								work_enable = 1'b0;
							end
						end
			
			Reset:	begin
							rjwrite = 4'd0;
							coeffwrite = 9'd0;
							datawrite = 8'd0;
							rj_enable = 1'b0;
							coeff_enable = 1'b0;
							data_enable = 1'b0;
							Clear = 1'b1;
							work_enable = 1'b0;
							InReady = 1'b0;
							sleep_flag = 1'b0;
							count_data = 8'd0;
							tk = 1'b0;
							if (Reset_n == 1'b0)
								state_next = Reset;
							else
								state_next = Wait_input;
						end
			
			Sleep:	begin
							rjwrite = 4'd0;
							coeffwrite = 9'd0;
							datawrite = datawrite;
							rj_enable = 1'b0;
							coeff_enable = 1'b0;
							data_enable = 1'b0;
							Clear = 1'b0;
							work_enable = 1'b0;
							InReady = 1'b1;
							sleep_flag = 1'b1;
							if (Reset_n == 1'b0)
								state_next = Reset;
							else if (in_flag == 1'b1 && tk == 1'b0)
							begin
								if (flag_zeroL && flag_zeroR)
									state_next = Sleep;
								else
								begin
									tk = 1'b1;
									data_enable = 1'b1;
									work_enable = 1'b1;
									sleep_flag = 1'b0;
									datawrite = count_data;
									count_data = count_data + 1'b1;
									count = count + 1'b1;
									state_next = Working;
								end
							end
							else
								state_next = Sleep;
						end
					
		endcase
		end
	end
endmodule
