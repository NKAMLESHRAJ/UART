create_clock -period 10.000 -name sysclk [get_ports fclk]

create_generated_clock -name genclk -source [get_ports fclk] -divide_by 6 [get_pins {brg/clk1/count_reg[5]/Q}]
create_generated_clock -name genclk1 -source [get_pins {brg/clk1/count_reg[5]/Q}] -divide_by 3 [get_pins {brg/count_reg[1]/Q}]
create_generated_clock -name genclk2 -source [get_pins {brg/count_reg[1]/Q}] -divide_by 2 [get_pins {brg/counter_reg[0]/Q}]
create_generated_clock -name genclk3 -source [get_pins {brg/counter_reg[0]/Q}] -divide_by 8 [get_pins {brg/counter_div_by_c_reg[2]/Q}]
set_clock_groups -asynchronous -group genclk -group genclk1 -group genclk2 -group genclk3

set_input_delay -clock sysclk 3.000 [all_inputs]
set_input_delay -clock sysclk -min 2.000 [all_inputs]
set_output_delay -clock sysclk 0.500 [all_outputs]
set_output_delay -clock sysclk -min 0.250 [all_outputs]
