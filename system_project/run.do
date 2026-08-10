vlib work
vlog -f alu_src_files.txt
vlog -f fifo_src_files.txt
vlog -f sub_modules_src_files.txt
vlog -f uart_rx_src_files.txt
vlog -f uart_tx_src_files.txt
vlog -f src_files.txt
vsim -voptargs=+acc work.sys_tb
do wave.do
run -all
#quit -sim