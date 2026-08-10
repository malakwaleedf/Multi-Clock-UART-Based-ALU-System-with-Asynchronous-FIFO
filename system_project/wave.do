onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sys_tb/REF_CLK_tb
add wave -noupdate /sys_tb/UART_CLK_tb
add wave -noupdate /sys_tb/TX_CLK_tb
add wave -noupdate -color Pink /sys_tb/RST_tb
add wave -noupdate -color Pink /sys_tb/RX_IN_tb
add wave -noupdate -color {Slate Blue} /sys_tb/TX_OUT_tb
add wave -noupdate /sys_tb/parallel_out
add wave -noupdate /sys_tb/Parity_Error_tb
add wave -noupdate /sys_tb/Stop_Error_tb
add wave -noupdate /sys_tb/DUT/U0_ref_sync/sync_bus
add wave -noupdate /sys_tb/DUT/U0_RegFile/regArr
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/cs
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/ns
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/RF_Address
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/RF_WrEn
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/RF_WrData
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/UART_RX_SYNC
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/UART_RX_V_SYNC
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/RF_RdEn
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/RF_RdData_VLD
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/RF_RdData
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/UART_TX_IN
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/UART_TX_VLD
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/ALU_FUN
add wave -noupdate /sys_tb/DUT/U0_SYS_CTRL/ALU_OUT
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/ALU_EN
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/ALU_OUT_VLD
add wave -noupdate -color Pink /sys_tb/DUT/U0_SYS_CTRL/CLKG_EN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {105356 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {73074 ns} {100608 ns}
