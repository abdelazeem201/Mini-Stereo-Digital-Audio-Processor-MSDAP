//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: ALU_Controller    
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
module alu_controller (
	input wire work_enable,
	input wire Clear,
	input wire Sclk,
	input wire sleep_flag,
	
	input wire [15:0] rjdataL, coeffdataL, indataL,
	input wire [15:0] rjdataR, coeffdataR, indataR,
	
	output wire [39:0] addL_input, addR_input,
	output reg rjL_enable, coeffL_enable, inputL_enable,
	output reg rjR_enable, coeffR_enable, inputR_enable,
	output reg addsubL, adderL_en, shiftL_en, loadL, clearL, p2sL_en,
	output reg addsubR, adderR_en, shiftR_en, loadR, clearR, p2sR_en,
        output reg [3:0] rjL_addr,
	output reg [8:0] coeffL_addr,
	output reg [7:0] inputL_addr,
	
	output reg [3:0] rjR_addr,
	output reg [8:0] coeffR_addr,
	output reg [7:0] inputR_addr
	
	
	);
	
	parameter start_ini_state = 2'b00, work_state = 2'b01, sleep_state = 2'b10;
	
	reg memL_overflow, start_workL, work_statusL, outL;
	reg memR_overflow, start_workR, work_statusR, outR;
	reg [1:0] present_stateL, next_stateL;
	reg [1:0] present_stateR, next_stateR;
	reg [7:0] kL, kR;
	reg [7:0] xcntL, x_indexL;
	reg [7:0] xcntR, x_indexR;
	
	assign addL_input = (indataL[15]) ? {8'hFF, indataL, 16'h0000} : {8'h00, indataL, 16'h0000};
	assign addR_input = (indataR[15]) ? {8'hFF, indataR, 16'h0000} : {8'h00, indataR, 16'h0000};
	
		
	always @(Clear, next_stateL)
	begin
		if (Clear == 1'b1)
			present_stateL <= start_ini_state;
		else
			present_stateL <= next_stateL;
	end
	
	always @(negedge Sclk)
	begin
		case (present_stateL)
			start_ini_state:
				begin
					memL_overflow <= 1'b0;
					if (Clear == 1'b1)
						next_stateL <= start_ini_state;
					else if (work_enable == 1'b1)
					begin
						next_stateL <= work_state;
						xcntL <= 8'd1;
						start_workL <= 1'b1;
						work_statusL <= 1'b1;
					end
					else
					begin
						next_stateL <= start_ini_state;
						xcntL <= xcntL;
						start_workL <= 1'b0;
					end
				end
			
			work_state:
				begin
					if (work_enable == 1'b1)
					begin
						xcntL <= xcntL + 1'b1;
						start_workL <= 1'b1;
						work_statusL <= 1'b1;
						if (xcntL == 8'hFF)
							memL_overflow <= 1'b1;
						else
							memL_overflow <= memL_overflow;
					end
					else
					begin
						start_workL <= 1'b0;
						memL_overflow <= memL_overflow;
						if (rjL_addr == 4'hF && coeffL_addr == 9'h1FF && kL == rjdataL)
							work_statusL <= 1'b0;
						else
							work_statusL <= work_statusL;
					end
					
					if (Clear == 1'b1)
						next_stateL <= start_ini_state;
					else if (sleep_flag == 1'b1)
						next_stateL <= sleep_state;
					else
						next_stateL <= work_state;
				end
			
			sleep_state:
				begin
					xcntL <= xcntL;
					memL_overflow <= memL_overflow;
					start_workL <= 1'b0;
					work_statusL <= 1'b0;
					if (Clear == 1'b1)
						next_stateL <= start_ini_state;
					else if (sleep_flag == 1'b0)
					begin
						xcntL <= xcntL + 1'b1;
						start_workL <= 1'b1;
						work_statusL <= 1'b1;
						if (xcntL == 8'hFF)
							memL_overflow <= 1'b1;
						else
							memL_overflow <= memL_overflow;
						next_stateL <= work_state;
					end
					else
						next_stateL <= sleep_state;
				end
				
			default:	next_stateL <= start_ini_state;
		endcase
	end
	
	always @(negedge Sclk)
	begin
		if (outL)
		begin
			p2sL_en = 1'b1;
			rjL_addr = 4'd0;
			coeffL_addr = 9'd0;
			kL = 8'd0;
			outL = 1'b0;
			clearL = 1'b1;
		end
		else
			p2sL_en = 1'b0;
		
		if (start_workL == 1'b1)
		begin
			outL = 1'b0;
			rjL_addr = 4'd0;
			rjL_enable = 1'b1;
			coeffL_addr = 9'd0;
			coeffL_enable = 1'b1;
			inputL_enable = 1'b0;
			adderL_en = 1'b0;
			shiftL_en = 1'b0;
			kL = 8'd0;
			clearL = 1'b1;
			loadL = 1'b0;
		end
		else if (work_statusL == 1'b1)
		begin
			if (kL == rjdataL)
			begin
				inputL_enable = 1'b0;
				shiftL_en = 1'b1;
				clearL = 1'b0;
				loadL = 1'b1;
				adderL_en = 1'b1;
				kL = 8'd0;
				if (rjL_addr < 4'd15)
				begin
					rjL_addr = rjL_addr + 1'b1;
				end
				else
				begin
					rjL_addr = 4'd0;
					outL = 1'b1;
					coeffL_addr = 9'd0;
				end
			end
			else
			begin
				shiftL_en = 1'b0;
				clearL = 1'b0;
				loadL = 1'b0;
				inputL_enable = 1'b0;
				x_indexL = coeffdataL[7:0];
				addsubL = coeffdataL[8];
				if (xcntL - 1'b1 >= x_indexL)
				begin
					inputL_addr = xcntL - 1'b1 - x_indexL;
					inputL_enable = 1'b1;
					adderL_en = 1'b1;
					loadL = 1'b1;
				end
				else if (xcntL - 1'b1 < x_indexL && memL_overflow == 1'b1)
				begin
					inputL_addr = xcntL - 1'b1 + (9'd256 - x_indexL);
					inputL_enable = 1'b1;
					adderL_en = 1'b1;
					loadL = 1'b1;
				end
				else
				begin
					inputL_addr = inputL_addr;
					adderL_en = 1'b0;
				end
				
				if (coeffL_addr < 9'h1FF)
					coeffL_addr = coeffL_addr + 1'b1;
				else
					coeffL_addr = coeffL_addr;
				
				kL = kL + 1'b1;
			end
		end
		else
		begin
			rjL_addr = 4'd0;
			rjL_enable = 1'b0;
			coeffL_addr = 9'd0;
			coeffL_enable = 1'b0;
			inputL_enable = 1'b0;
			adderL_en = 1'b0;
			shiftL_en = 1'b0;
			kL = 8'd0;
			loadL = 1'b0;
			clearL = 1'b1;
		end
	end
	
	
	// Right side FSM
	
	always @(Clear, next_stateR)
	begin
		if (Clear == 1'b1)
			present_stateR <= start_ini_state;
		else
			present_stateR <= next_stateR;
	end
	
	always @(negedge Sclk)
	begin
		case (present_stateR)
			start_ini_state:
				begin
					memR_overflow <= 1'b0;
					if (Clear == 1'b1)
						next_stateR <= start_ini_state;
					else if (work_enable == 1'b1)
					begin
						next_stateR <= work_state;
						xcntR <= 8'd1;
						start_workR <= 1'b1;
						work_statusR <= 1'b1;
					end
					else
					begin
						next_stateR <= start_ini_state;
						xcntR <= xcntR;
						start_workR <= 1'b0;
					end
				end
			
			work_state:
				begin
					if (work_enable == 1'b1)
					begin
						xcntR <= xcntR + 1'b1;
						start_workR <= 1'b1;
						work_statusR <= 1'b1;
						if (xcntR == 8'hFF)
							memR_overflow <= 1'b1;
						else
							memR_overflow <= memR_overflow;
					end
					else
					begin
						start_workR <= 1'b0;
						memR_overflow <= memR_overflow;
						if (rjR_addr == 4'hF && coeffR_addr == 9'h1FF && kR == rjdataR)
							work_statusR <= 1'b0;
						else
							work_statusR <= work_statusR;
					end
					
					if (Clear == 1'b1)
						next_stateR <= start_ini_state;
					else
						next_stateR <= work_state;
				end
			
			sleep_state:
				begin
					xcntR <= xcntR;
					memR_overflow <= memR_overflow;
					start_workR <= 1'b0;
					work_statusR <= 1'b0;
					if (Clear == 1'b1)
						next_stateR <= start_ini_state;
					else if (sleep_flag == 1'b0)
					begin
						xcntR <= xcntR + 1'b1;
						start_workR <= 1'b1;
						work_statusR <= 1'b1;
						if (xcntR == 8'hFF)
							memR_overflow <= 1'b1;
						else
							memR_overflow <= memR_overflow;
						next_stateR <= work_state;
					end
					else
						next_stateR <= sleep_state;
				end
				
			default:
				begin
				end
		endcase
	end
	
	always @(negedge Sclk)
	begin
		if (outR)
		begin
			p2sR_en = 1'b1;
			rjR_addr = 4'd0;
			coeffR_addr = 9'd0;
			kR = 8'd0;
			outR = 1'b0;
		end
		else
			p2sR_en = 1'b0;
		
		if (start_workR == 1'b1)
		begin
			outR = 1'b0;
			rjR_addr = 4'd0;
			rjR_enable = 1'b1;
			coeffR_addr = 9'd0;
			coeffR_enable = 1'b1;
			inputR_enable = 1'b0;
			adderR_en = 1'b0;
			shiftR_en = 1'b0;
			kR = 8'd0;
			clearR = 1'b1;
			loadR = 1'b0;
		end
		else if (work_statusR == 1'b1)
		begin
			if (kR == rjdataR)
			begin
				inputR_enable = 1'b0;
				shiftR_en = 1'b1;
				clearR = 1'b0;
				loadR = 1'b1;
				adderR_en = 1'b1;
				kR = 8'd0;
				if (rjR_addr < 4'd15)
				begin
					rjR_addr = rjR_addr + 1'b1;
				end
				else
				begin
					rjR_addr = 4'd0;
					outR = 1'b1;
					coeffR_addr = 9'd0;
				end
			end
			else
			begin
				shiftR_en = 1'b0;
				clearR = 1'b0;
				loadR = 1'b0;
				inputR_enable = 1'b0;
				x_indexR = coeffdataR[7:0];
				addsubR = coeffdataR[8];
				if (xcntR - 1'b1 >= x_indexR)
				begin
					inputR_addr = xcntR - 1'b1 - x_indexR;
					inputR_enable = 1'b1;
					adderR_en = 1'b1;
					loadR = 1'b1;
				end
				else if (xcntR - 1'b1 < x_indexR && memR_overflow == 1'b1)
				begin
					inputR_addr = xcntR - 1'b1 + (9'd256 - x_indexR);
					inputR_enable = 1'b1;
					adderR_en = 1'b1;
					loadR = 1'b1;
				end
				else
				begin
					inputR_addr = inputR_addr;
					adderR_en = 1'b0;
				end
				
				if (coeffR_addr < 9'h1FF)
					coeffR_addr = coeffR_addr + 1'b1;
				else
					coeffR_addr = coeffR_addr;
				
				kR = kR + 1'b1;
			end
		end
		else
		begin
			rjR_addr = 4'd0;
			rjR_enable = 1'b0;
			coeffR_addr = 9'd0;
			coeffR_enable = 1'b0;
			inputR_enable = 1'b0;
			adderR_en = 1'b0;
			shiftR_en = 1'b0;
			kR = 8'd0;
			loadR = 1'b0;
			clearR = 1'b1;
		end
	end
	
endmodule
