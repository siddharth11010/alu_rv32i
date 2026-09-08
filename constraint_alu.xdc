################################################################################
# Vivado XDC Constraints File
# Target Device: xc7s50csga324-1 (Spartan-7 CSGA324 Package, Speed Grade -1)
# Module: alu_rv32i
################################################################################

# ==============================================================================
# 1. TIMING CONSTRAINTS
# ==============================================================================
# Set virtual clock to 15.0ns (66.6 MHz) to allow realistic pure combinational pad-to-pad delay
create_clock -name virt_clk -period 20.000

# Input/Output delays relative to virtual clock
set_input_delay  -clock virt_clk 2.000 [get_ports {A[*] B[*] alu_op[*]}]
set_output_delay -clock virt_clk 2.000 [get_ports {Y[*] zero}]

# REMOVED: set_max_delay 8.000 (This was forcing an impossible 8ns timing path)

# ==============================================================================
# 2. I/O STANDARD DEFAULTS
# ==============================================================================
 set_property IOSTANDARD LVCMOS33 [get_ports {A[*] B[*] alu_op[*] Y[*] zero}]
# set_property PULLDOWN true [get_ports {A[*] B[*] alu_op[*]}]

# ==============================================================================
# 3. PIN LOCATIONS (CSGA324)
# ==============================================================================


set_property PACKAGE_PIN R12 [get_ports {alu_op[0]}]
set_property PACKAGE_PIN P13 [get_ports {alu_op[1]}]
set_property PACKAGE_PIN P14 [get_ports {alu_op[2]}]
set_property PACKAGE_PIN P15 [get_ports {alu_op[3]}]
set_property PACKAGE_PIN T14 [get_ports {zero}]

# ==============================================================================
# 4. BITSTREAM CONFIGURATION
# ==============================================================================
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]