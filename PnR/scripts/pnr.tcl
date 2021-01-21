##############################################
########### 1. DESIGN SETUP ##################
##############################################

set design top
set clk Sclk


sh rm -rf $design

set sc_dir "/home/ahesham/Desktop/Abdelazeem/MSDAP/Library Work"

set_app_var search_path "/home/ahesham/Desktop/Desktop/ref/models"

set_app_var link_library "* fast.db slow.db SP018N_V1p0_max.db.db typical.db SP018N_V1p0_max.db.db SP018N_V1p0_min.db SP018N_V1p0_typ.db"
set_app_var target_library "fast.db slow.db SP018N_V1p0_max.db.db SP018N_V1p0_min.db"


create_mw_lib   ./${design} \
                -technology $sc_dir/techfile/SmicVTTF_log018.tf \
		-mw_reference_library $sc_dir/smic18 \
		 -open

set tlupmax "$sc_dir/itf_tluplus/smiclog018_4lm_cell_max.tluplus"
set tlupmin "$sc_dir/itf_tluplus/smiclog018_4lm_tran_min.tluplus"
set tech2itf "$sc_dir/itf_tluplus/Mrmap.map"

set_tlu_plus_files -max_tluplus $tlupmax \
                   -min_tluplus $tlupmin \
     		   -tech2itf_map $tech2itf


import_designs  ../syn/output/${design}.v \
                        -format verilog \
		        -top ${design} \
		        -cel ${design}


source  ../syn/cons/cons.tcl

save_mw_cel -as ${design}_1_imported

##############################################
########### 2. Floorplan #####################
##############################################

## Create Starting Floorplan
############################
create_floorplan -core_utilization 0.6 \
	-start_first_row -flip_first_row \
	-left_io2core 20 -bottom_io2core 20 -right_io2core 20 -top_io2core 20


## Initial Virtual Flat Placement
#################################
## Use the following command with any of its options to meet a specific target
#    create_fp_placement -timing -no_hierarchy_gravity -congestion 

create_fp_placement


save_mw_cel -as ${design}_2_fp


##################################################
########### 3. POWER NETWORK #####################
##################################################

## Defining Logical POWER/GROUND Connections
############################################
derive_pg_connection 	 -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	


## Define Power Ring 
####################
set_fp_rail_constraints  -set_ring -nets  {VDD VSS}  \
                         -horizontal_ring_layer { METAL3 METAL5 } \
                         -vertical_ring_layer { METAL4 METAL6 } \
			 -ring_spacing 1 \
			 -ring_width 2 \
			 -ring_offset 5 \
			 -extend_strap core_ring

## Define Power Mesh 
####################
set_fp_rail_constraints -add_layer  -layer METAL6 -direction vertical   -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer METAL5  -direction horizontal -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer METAL4  -direction vertical   -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer METAL3  -direction horizontal -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer METAL2  -direction vertical   -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum


set_fp_rail_constraints -set_global

## Creating virtual PG pads
###########################
# you can create them with gui. Preroute > Create Virtual Power Pad
set die_llx [lindex [lindex [ get_attribute [get_die_area] bbox] 0] 0]
set die_lly [lindex [lindex [ get_attribute [get_die_area] bbox] 0] 1]
set die_urx [lindex [lindex [ get_attribute [get_die_area] bbox] 1] 0]
set die_ury [lindex [lindex [ get_attribute [get_die_area] bbox] 1] 1]

for {set i "[expr $die_llx + 20]"} {$i < "[expr $die_urx - 40]"} {set i [expr $i + 80]} {
	create_fp_virtual_pad -net VSS -point "{$i $die_lly}"
	create_fp_virtual_pad -net VDD -point "{[expr $i + 40] $die_lly}"

	create_fp_virtual_pad -net VSS -point "{$i $die_ury}"
	create_fp_virtual_pad -net VDD -point "{[expr $i + 40] $die_ury}"
}

for {set i "[expr $die_lly + 20]"} {$i < "[expr $die_ury - 40]"} {set i [expr $i + 80]} {
	create_fp_virtual_pad -net VSS -point "{$die_llx $i}"
	create_fp_virtual_pad -net VDD -point "{$die_llx [expr $i + 40]}"

	create_fp_virtual_pad -net VSS -point "{$die_urx $i}"
	create_fp_virtual_pad -net VDD -point "{$die_urx [expr $i + 40] }"
}




synthesize_fp_rail  -nets {VDD VSS} -synthesize_power_plan -target_voltage_drop 24 -voltage_supply 1.2 -power_budget 150


commit_fp_rail

set_preroute_drc_strategy -max_layer METAL4
preroute_standard_cells -fill_empty_rows -remove_floating_pieces



## Add Well Tie Cells
#####################
add_tap_cell_array -master   TAP \
     		   -distance 30 \
     		   -pattern  stagger_every_other_row

save_mw_cel -as ${design}_3_power

##############################################
########### 4. Placement #####################
##############################################
puts "start_place"

## CHECKS
#########
report_ignored_layers ; # To Make sure they are as wanted.
check_physical_design -stage pre_place_opt
check_physical_constraints



## INITIAL PLACEMENT
####################

place_opt


## OPTIMIZATION
###############
# psynopt -area_recovery |-power| |-congestion| 
psynopt


## FINAL ASSESSMENT
###################

check_legality


# DEFINING POWER/GROUND NETS AND PINS			 
derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	

## Tie fixed values
set tie_pins [get_pins -all -filter "constant_value == 0 || constant_value == 0 && name !~ V* && is_hierarchical == false "]


derive_pg_connection 	 -power_net VDD		\
			 -ground_net VSS	\
			 -tie


connect_tie_cells -objects $tie_pins \
                  -obj_type port_inst \
		  -tie_low_lib_cell  LOGIC0_X1 \
		  -tie_high_lib_cell LOGIC1_X1





puts "finish_place"

save_mw_cel -as ${design}_4_placed

##############################################
########### 5. CTS       #####################
##############################################

puts "start_cts"

## CHECKS
#########
check_physical_design -stage pre_clock_opt 
check_clock_tree 
report_clock_tree


## CONSTRAINTS 
##############
## Here, We define more constraints on your design that are related to CTS stage.

set_driving_cell -lib_cell BUF_X16 -pin Z [get_ports $clk]


#### Set Clock Exceptions


### Set Clock Control/Targets
set_clock_tree_options \
                -clock_trees $clk \
		-target_early_delay 0.1 \
		-target_skew 0.5 \
		-max_capacitance 300 \
		-max_fanout 10 \
		-max_transition 0.150

set_clock_tree_options -clock_trees $clk \
		-buffer_relocation true \
		-buffer_sizing true \
		-gate_relocation true \
		-gate_sizing true 




### Set Clock Physical Constraints
## Clock Non-Default Ruls (NDR) - Set it to be double width and double spacing 
define_routing_rule my_route_rule  \
  -widths   {metal3 0.14 metal4 0.28 METAL3 0.28} \
  -spacings {metal3 0.14 metal4 0.28 METAL3 0.28} 

set_clock_tree_options -clock_trees $clk \
                       -routing_rule my_route_rule  \
		       -layer_list "METAL3 METAL4 METAL5"

## To avoid NDR at clock sinks
set_clock_tree_options -use_default_routing_for_sinks 1

report_clock_tree -settings


## Clock Tree : Synhtesis, Optimization, and Routing
####################################################
## The 3 steps can be done with the combo command clock_opt. But below, we do them individually.

## 1- CTS 
clock_opt -only_cts -no_clock_route
## analyze
    report_design_physical -utilization
    report_clock_tree -summary ; # reports for the clock tree, regardless of relation between FFs
    report_clock_tree
    report_clock_timing -type summary ; # reports for the clock tree, considering relation between FFs
    report_timing
    report_timing -delay_type min
    report_constraints -all_violators -max_delay -min_delay
 


## 2- CTO
## To Consider Hold Fix -- Design Dependent
   set_fix_hold [all_clocks]
   set_fix_hold_options -prioritize_tns
set_propagated_clock [all_clocks]
clock_opt -only_psyn -no_clock_route
#analyze


## 3- Clock Tree Routing
route_group -all_clock_nets
#analyze


## If any issue at analysis, update CT constraints 
##################################################

# DEFINING POWER/GROUND NETS AND PINS			 
derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	
			 
save_mw_cel -as ${design}_5_cts

puts "finish_cts"

##############################################
########### 6. Routing   #####################
##############################################

## Before starting to route, you should add spare cells
insert_spare_cells -lib_cell {NOR2_X4 NAND2_X4} \
		   -num_instances 20 \
		   -cell_name SPARE_PREFIX_NAME \
		   -tie

set_dont_touch  [all_spare_cells] true
set_attribute [all_spare_cells]  is_soft_fixed true

##############################################

puts "start_route"

check_physical_design -stage pre_route_opt; # dump check_physical_design result to file ./cpd_pre_route_opt_*/index.html
all_ideal_nets
all_high_fanout -nets -threshold 100
check_routeability


set_delay_calculation_options -arnoldi_effort low


set_route_options -groute_timing_driven true \
	          -groute_incremental true \
	          -track_assign_timing_driven true \
	          -same_net_notch check_and_fix 

set_si_options -route_xtalk_prevention true\
	       -delta_delay true \
	       -min_delta_delay true \
	       -static_noise true\
	       -timing_window true 



   set_fix_hold [all_clocks]
   set_prefer -min  [get_lib_cells "*/BUF_X2 */BUF_X1"]
   set_fix_hold_options -preferred_buffer

set_propagated_clock [all_clocks]
route_opt

psynopt  -only_hold_time -congestion
route_zrt_eco -open_net_driven true
verify_zrt_route
route_zrt_detail -incremental true -initial_drc_from_input true
#route_opt -effort high -stage track -xtalk_reduction

derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	




#report_noise
#report_timing -crosstalk_delta


save_mw_cel -as ${design}_6_routed

puts "finish_route"

##############################################
########### 7. Finishing #####################
##############################################


insert_stdcell_filler -cell_without_metal {FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1} \
	-connect_to_power VDD -connect_to_ground VSS

insert_zrt_redundant_vias 

derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	

save_mw_cel -as ${design}_7_finished

save_mw_cel -as ${design}

##############################################
########### 8. Checks and Outputs ############
##############################################

verify_zrt_route
verify_lvs -ignore_floating_port -ignore_floating_net \
           -check_open_locator -check_short_locator

set_write_stream_options -map_layer $sc_dir/tech/strmout/FreePDK45_10m_gdsout.map \
                         -output_filling fill \
			 -child_depth 20 \
			 -output_outdated_fill  \
			 -output_pin  {text geometry}

write_stream -lib $design \
                  -format gds\
		  -cells $design\
		  ./output/${design}.gds



define_name_rules  no_case -case_insensitive
change_names -rule no_case -hierarchy
change_names -rule verilog -hierarchy
set verilogout_no_tri	 true
set verilogout_equation  false


write_verilog -pg -no_physical_only_cells ./output/${design}_icc.v
write_verilog -no_physical_only_cells ./output/${design}_icc_nopg.v

extract_rc
write_parasitics -output ./output/${design}.spef


close_mw_cel
close_mw_lib

exit
