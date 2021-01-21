set timing_enable_multiple_clocks_per_reg  true
set clk_margin 1.0
set max_fanout 10
create_clock -period 40 -waveform {0 20} [get_ports {Sclk}]
create_clock -period 1302 -waveform {0 651} [get_ports {Dclk}]
set_input_transition 0.2 [get_ports Sclk]
set_input_transition 0.2 [get_ports Dclk]
set_input_delay 1.0 -clock Sclk  [get_ports Reset_n]
set_input_delay 1.0 -clock Sclk  [get_ports Start]
set_input_delay 1.0 -clock Dclk  [get_ports InputL]
set_input_delay 1.0 -clock Dclk  [get_ports InputR]
set_input_delay 1.0 -clock Dclk  [get_ports Frame]
set_output_delay 1.0  -clock Sclk [get_ports OutputL]
set_output_delay 1.0  -clock Sclk [get_ports OutputR]
set_output_delay 1.0  -clock Sclk [get_ports InReady]
set_output_delay 1.0  -clock Dclk [get_ports OutReady]


