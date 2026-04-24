# ==============================================================
# traffic_case4 - ZedBoard XDC Constraints
# ==============================================================

# System Clock
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

# Reset
set_property PACKAGE_PIN T18 [get_ports rst]
set_property IOSTANDARD LVCMOS18 [get_ports rst]

# ==============================================================
# IR SENSORS - All Roads
# ==============================================================

# Road A
set_property PACKAGE_PIN Y11 [get_ports a1]
set_property PACKAGE_PIN AA11 [get_ports a2]
set_property PACKAGE_PIN Y10 [get_ports a3]

# Road B
set_property PACKAGE_PIN AA9  [get_ports b1]
set_property PACKAGE_PIN AB11 [get_ports b2]
set_property PACKAGE_PIN AB10 [get_ports b3]

# Road C
set_property PACKAGE_PIN AB9 [get_ports c1]
set_property PACKAGE_PIN AA8 [get_ports c2]
set_property PACKAGE_PIN W12 [get_ports c3]

# Road D
set_property PACKAGE_PIN W11 [get_ports d1]
set_property PACKAGE_PIN V10 [get_ports d2]
set_property PACKAGE_PIN W8  [get_ports d3]

set_property IOSTANDARD LVCMOS33 [get_ports {a1 a2 a3 b1 b2 b3 c1 c2 c3 d1 d2 d3}]

# ==============================================================
# EMERGENCY INPUTS
# ==============================================================

set_property PACKAGE_PIN V12 [get_ports sa]
set_property PACKAGE_PIN W10 [get_ports sb]
set_property PACKAGE_PIN V9  [get_ports sc]
set_property PACKAGE_PIN V8  [get_ports sd]

set_property IOSTANDARD LVCMOS33 [get_ports {sa sb sc sd}]

# ==============================================================
# OUTPUTS
# ==============================================================

# Road A
set_property PACKAGE_PIN AB6 [get_ports {A[0]}]
set_property PACKAGE_PIN AB7 [get_ports {A[1]}]
set_property PACKAGE_PIN AA4 [get_ports {A[2]}]

# Road B
set_property PACKAGE_PIN Y4 [get_ports {B[0]}]
set_property PACKAGE_PIN T6 [get_ports {B[1]}]
set_property PACKAGE_PIN R6 [get_ports {B[2]}]

# Road C
set_property PACKAGE_PIN U4 [get_ports {C[0]}]
set_property PACKAGE_PIN T4 [get_ports {C[1]}]
set_property PACKAGE_PIN W7 [get_ports {C[2]}]

# Road D
set_property PACKAGE_PIN V7 [get_ports {D[0]}]
set_property PACKAGE_PIN V4 [get_ports {D[1]}]
set_property PACKAGE_PIN V5 [get_ports {D[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {A B C D}]

# ==============================================================
# TIMING CONSTRAINTS
# ==============================================================

# Input delays
set_input_delay -clock sys_clk -max 5ns [get_ports {a1 a2 a3 b1 b2 b3 c1 c2 c3 d1 d2 d3}]
set_input_delay -clock sys_clk -min 0ns [get_ports {a1 a2 a3 b1 b2 b3 c1 c2 c3 d1 d2 d3}]

set_input_delay -clock sys_clk -max 5ns [get_ports {sa sb sc sd}]
set_input_delay -clock sys_clk -min 0ns [get_ports {sa sb sc sd}]

# Output delays
set_output_delay -clock sys_clk -max 5ns [get_ports {A[0] A[1] A[2]}]
set_output_delay -clock sys_clk -min 0ns [get_ports {A[0] A[1] A[2]}]

set_output_delay -clock sys_clk -max 5ns [get_ports {B[0] B[1] B[2]}]
set_output_delay -clock sys_clk -min 0ns [get_ports {B[0] B[1] B[2]}]

set_output_delay -clock sys_clk -max 5ns [get_ports {C[0] C[1] C[2]}]
set_output_delay -clock sys_clk -min 0ns [get_ports {C[0] C[1] C[2]}]

set_output_delay -clock sys_clk -max 5ns [get_ports {D[0] D[1] D[2]}]
set_output_delay -clock sys_clk -min 0ns [get_ports {D[0] D[1] D[2]}]

# False paths
set_false_path -from [get_ports {a1 a2 a3 b1 b2 b3 c1 c2 c3 d1 d2 d3}]
set_false_path -from [get_ports {sa sb sc sd}]
set_false_path -from [get_ports rst]
