# ==============================================================================
# CYCLONE IV E PIN MAPPING (Defaults for Altera DE2-115 Board)
# ==============================================================================

# 1. Main 50MHz Clock (DE2-115 uses PIN_Y2, DE0-Nano uses PIN_R8)
set_location_assignment PIN_Y2 -to clk_50mhz

# 2. Reset Button / KEY0 - Active Low (DE2-115 uses PIN_M23)
set_location_assignment PIN_M23 -to cpu_reset_n

# 3. 8 Green LEDs (DE2-115 LEDG[7:0])
set_location_assignment PIN_G21 -to user_led[7]
set_location_assignment PIN_G22 -to user_led[6]
set_location_assignment PIN_G20 -to user_led[5]
set_location_assignment PIN_H21 -to user_led[4]
set_location_assignment PIN_E24 -to user_led[3]
set_location_assignment PIN_E25 -to user_led[2]
set_location_assignment PIN_E22 -to user_led[1]
set_location_assignment PIN_E21 -to user_led[0]

# ==============================================================================
# VOLTAGE STANDARDS (Cyclone IV E normally uses 3.3-V or 2.5-V)
# ==============================================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_50mhz
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to cpu_reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to user_led*