set_global_assignment -entity "PLL33" -library "lib_PLL33" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "PLL33" -library "lib_PLL33" -name IP_TOOL_VERSION "16.1"
set_global_assignment -entity "PLL33" -library "lib_PLL33" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_PLL33" -name SPD_FILE [file join $::quartus(sip_path) "PLL33.spd"]

set_global_assignment -library "lib_PLL33" -name MISC_FILE [file join $::quartus(sip_path) "PLL33_sim/PLL33.vo"]
