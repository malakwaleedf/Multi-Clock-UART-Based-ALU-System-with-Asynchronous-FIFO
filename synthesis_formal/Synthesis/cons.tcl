
####################################################################################
# Constraints
# ----------------------------------------------------------------------------
#
# 0. Design Compiler variables
#
# 1. Master Clock Definitions
#
# 2. Generated Clock Definitions
#
# 3. Clock Uncertainties
#
# 4. Clock Latencies 
#
# 5. Clock Relationships
#
# 6. #set input/output delay on ports
#
# 7. Driving cells
#
# 8. Output load

####################################################################################
           #########################################################
                  #### Section 0 : DC Variables ####
           #########################################################
#################################################################################### 

# Prevent assign statements in the generated netlist (must be applied before compile command)
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs

####################################################################################
           #########################################################
                  #### Section 1 : Clock Definition ####
           #########################################################
#################################################################################### 
# 1. Master Clock Definitions 
# 2. Generated Clock Definitions
# 3. Clock Latencies
# 4. Clock Uncertainties
# 4. Clock Transitions
####################################################################################

#1. Master Clocks
create_clock -period 20 -name "REF_CLK" [get_ports REF_CLK]
create_clock -period 271.3 -name "UART_CLK" [get_ports UART_CLK]

#2. Generated clocks
create_generated_clock -master "UART_CLK" -source [get_ports UART_CLK] -name "UART_TX_CLK" -divide_by 32 [get_ports U0_UART/TX_CLK]
create_generated_clock -master "UART_CLK" -source [get_ports UART_CLK] -name "UART_RX_CLK" -divide_by 1 [get_ports U0_UART/RX_CLK]
create_generated_clock -master "REF_CLK" -source [get_ports REF_CLK] -name "ALU_CLK" -divide_by 1 [get_ports U0_ALU/CLK]

set_clock_latency 0 [get_clocks {REF_CLK UART_CLK UART_TX_CLK UART_RX_CLK ALU_CLK}]
set_clock_uncertainty -setup 0.2 [get_clocks {REF_CLK UART_CLK UART_TX_CLK UART_RX_CLK ALU_CLK}]
set_clock_uncertainty -hold 0.1 [get_clocks {REF_CLK UART_CLK UART_TX_CLK UART_RX_CLK ALU_CLK}]
set_clock_transition 0.05 [get_clocks {REF_CLK UART_CLK}]

set_dont_touch_network {REF_CLK UART_CLK UART_TX_CLK UART_RX_CLK ALU_CLK}

####################################################################################
           #########################################################
             #### Section 2 : Clocks Relationship ####
           #########################################################
####################################################################################

set_clock_groups -asynchronous -group [get_clocks {REF_CLK ALU_CLK}] -group [get_clocks {UART_CLK UART_TX_CLK UART_RX_CLK}]

####################################################################################
           #########################################################
             #### Section 3 : set input/output delay on ports ####
           #########################################################
####################################################################################

set_input_delay 4 -clock REF_CLK [get_ports UART_RX_IN]
set_output_delay 4 -clock REF_CLK [get_ports {UART_TX_O parity_error framing_error}]

####################################################################################
           #########################################################
                  #### Section 4 : Driving cells ####
           #########################################################
####################################################################################

set_driving_cell -library scmetro_tsmc_cl013g_rvt_ss_1p08v_125c -lib_cell BUFX2M -pin Y [get_ports UART_RX_IN]

####################################################################################
           #########################################################
                  #### Section 5 : Output load ####
           #########################################################
####################################################################################

set_load 0.1 [get_ports {UART_TX_O parity_error framing_error}]

####################################################################################
           #########################################################
                 #### Section 6 : Operating Condition ####
           #########################################################
####################################################################################

# Define the Worst Library for Max(#setup) analysis
# Define the Best Library for Min(hold) analysis

set_operating_conditions -min_library "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -min "scmetro_tsmc_cl013g_rvt_ff_1p32v_m40c" -max_library "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c" -max "scmetro_tsmc_cl013g_rvt_ss_1p08v_125c"

####################################################################################
           #########################################################
                  #### Section 7 : wireload Model ####
           #########################################################
####################################################################################


####################################################################################
           #########################################################
                  #### Section 8 : premapped cells ####
           #########################################################
####################################################################################


####################################################################################

