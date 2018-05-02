set_global_assignment -entity "PLL100" -library "lib_PLL100" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL100" -library "lib_PLL100" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "PLL100" -library "lib_PLL100" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL100" -name SPD_FILE [file join $::quartus(sip_path) "PLL100.spd"]

set_global_assignment -library "lib_PLL100" -name MISC_FILE [file join $::quartus(sip_path) "PLL100_sim/PLL100.vo"]
