//////////////////////////////////////////////////////////////////////////////////
// Company: Zagazig University
// Engineer: Ahmed Abdelazeem
// 
// Create Date:    20:58:48 01/16/2021 
// Design Name: MSDAP
// Module Name: TOP-Module   
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

module top(
         input wire Dclk, Sclk, Reset_n, Frame, Start, InputL, InputR,
	 output wire InReady, OutReady, OutputL, OutputR );
				 
	
// Wires for memories
wire rj_enable, coeff_enable, data_enable;				

// Wires for main controller
wire rjL_enable, coeffL_enable, inputL_enable; 		

// Wires for ALU controller
wire rjR_enable, coeffR_enable, inputR_enable;
wire [3:0] rjwrite, rjL_addr, rjR_addr;
wire [8:0] coeffwrite, coeffL_addr, coeffR_addr;
wire [7:0] datawrite, inputL_addr, inputR_addr;
wire [15:0] rjdataL, coeffdataL, indataL;
wire [15:0] rjdataR, coeffdataR, indataR;
wire flag_zeroL, flag_zeroR;
	
// Wires for ALU controller
wire [39:0] addL_input, addR_input;
wire addsubL, adderL_en, shiftL_en, loadL, clearL, p2sL_en;
wire addsubR, adderR_en, shiftR_en, loadR, clearR, p2sR_en;
	
// Wires for adder, shifter blocks
wire [39:0] Shift_done_L, Shift_done_R, sum_L, sum_R;
	
//Wires for PISO
wire OutReadyL, OutReadyR;
	
//Wires for SIPO
wire Frame_in, Dclk_in, Clear, in_flag;
wire [15:0] dataL, dataR;
	
//Wires for main controller
wire work_enable, sleep_flag, Sclk_in;

// assign addL_input = (indataL[15]) ? {8'hFF, indataL, 16'h0000} : {8'h00, indataL, 16'h0000};
// assign addR_input = (indataR[15]) ? {8'hFF, indataR, 16'h0000} : {8'h00, indataR, 16'h0000};
	
//Module instantiations
rj_memory rjL (.write_enable(rj_enable), .read_enable(rjL_enable), .Sclk(Sclk_in),
	       .rjwrite(rjwrite), .rjread(rjL_addr), .in_data(dataL), .data_rj(rjdataL));
	
rj_memory rjR (.write_enable(rj_enable), .read_enable(rjR_enable), .Sclk(Sclk_in),
	       .rjwrite(rjwrite), .rjread(rjR_addr), .in_data(dataR), .data_rj(rjdataR));
					
coeff_memory coeffL (.write_enable(coeff_enable), .read_enable(coeffL_enable), .Sclk(Sclk_in),
		     .coeffwrite(coeffwrite), .coeffread(coeffL_addr), .in_data(dataL), .data_coeff(coeffdataL));
	
coeff_memory coeffR (.write_enable(coeff_enable), .read_enable(coeffR_enable), .Sclk(Sclk_in),
		     .coeffwrite(coeffwrite), .coeffread(coeffR_addr), .in_data(dataR), .data_coeff(coeffdataR));

data_memory inL (.write_enable(data_enable), .read_enable(inputL_enable), .Sclk(Sclk_in), .in_flag(in_flag),
		 .datawrite(datawrite), .dataread(inputL_addr), .in_data(dataL), .input_data(indataL), .flag_zero(flag_zeroL));

data_memory inR (.write_enable(data_enable), .read_enable(inputR_enable), .Sclk(Sclk_in), .in_flag(in_flag),
		 .datawrite(datawrite), .dataread(inputR_addr), .in_data(dataR), .input_data(indataR), .flag_zero(flag_zeroR));
					   
main_controller main_ctrl (.Sclk(Sclk), .Dclk(Dclk), .Start(Start), .Reset_n(Reset_n),
			   .Frame(Frame), .in_flag(in_flag), .flag_zeroL(flag_zeroL), .flag_zeroR(flag_zeroR),
			   .rjwrite(rjwrite), .coeffwrite(coeffwrite), .datawrite(datawrite),
			   .rj_enable(rj_enable), .coeff_enable(coeff_enable), .data_enable(data_enable), .Clear(Clear),
			   .Frame_out(Frame_in), .Dclk_out(Dclk_in), .Sclk_out(Sclk_in),
			   .work_enable(work_enable), .sleep_flag(sleep_flag), .InReady(InReady));
	
alu_controller alu_ctrl (.work_enable(work_enable), .Clear(Clear), .Sclk(Sclk_in), .sleep_flag(sleep_flag),
			 .rjdataL(rjdataL), .coeffdataL(coeffdataL), .indataL(indataL),
			 .rjdataR(rjdataR), .coeffdataR(coeffdataR), .indataR(indataR),
			 .addL_input(addL_input), .addR_input(addR_input),
			 .rjL_addr(rjL_addr), .coeffL_addr(coeffL_addr), .inputL_addr(inputL_addr),
			 .rjR_addr(rjR_addr), .coeffR_addr(coeffR_addr), .inputR_addr(inputR_addr),
			 .rjL_enable(rjL_enable), .coeffL_enable(coeffL_enable), .inputL_enable(inputL_enable),
			 .rjR_enable(rjR_enable), .coeffR_enable(coeffR_enable), .inputR_enable(inputR_enable),
			 .addsubL(addsubL), .adderL_en(adderL_en), .shiftL_en(shiftL_en), .loadL(loadL), .clearL(clearL), .p2sL_en(p2sL_en),
			 .addsubR(addsubR), .adderR_en(adderR_en), .shiftR_en(shiftR_en), .loadR(loadR), .clearR(clearR), .p2sR_en(p2sR_en));
							 
adder addL (.a(addL_input), .b(Shift_done_L), .addsub(addsubL), .adder_en(adderL_en), .sum(sum_L));
	
adder addR (.a(addR_input), .b(Shift_done_R), .addsub(addsubR), .adder_en(adderR_en), .sum(sum_R));
	
shift_accumulator shiftL (.shift_en(shiftL_en), .load(loadL), .clear(clearL), .sclk(Sclk_in), .in_bk(sum_L), .out_bk(Shift_done_L));
	
shift_accumulator shiftR (.shift_en(shiftR_en), .load(loadR), .clear(clearR), .sclk(Sclk_in), .in_bk(sum_R), .out_bk(Shift_done_R));
	
PISO PISOL (.Sclk(Sclk_in), .Clear(Clear), .Frame(Frame_in), .Shift_done(Shift_done_L), .SerialOut(OutputL), .p2s_en(p2sL_en), .OutReady(OutReadyL));
	
PISO PISOR (.Sclk(Sclk_in), .Clear(Clear), .Frame(Frame_in), .Shift_done(Shift_done_R), .SerialOut(OutputR), .p2s_en(p2sR_en), .OutReady(OutReadyR));

SIPO Sipo (.Frame(Frame_in), .Dclk(Dclk_in), .Clear(Clear), .InputL(InputL), .InputR(InputR), .in_flag(in_flag), .dataL(dataL), .dataR(dataR));

assign OutReady = OutReadyL || OutReadyR;
	
endmodule
