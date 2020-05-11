onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/clk
add wave -noupdate /top_tb/rst
add wave -noupdate /top_tb/top/pc/cur_inst
add wave -noupdate /top_tb/top/regs/regs
add wave -noupdate /top_tb/top/alu/alu_control
add wave -noupdate /top_tb/top/alu/alu_result
add wave -noupdate /top_tb/top/alu/data_a
add wave -noupdate /top_tb/top/alu/data_b
add wave -noupdate /top_tb/top/alu/ALUSrc
add wave -noupdate /top_tb/top/opcode_control/ALUSrc
add wave -noupdate /top_tb/top/opcode_control/ALUOp
add wave -noupdate /top_tb/top/opcode_control/opcode
add wave -noupdate /top_tb/top/opcode_control/control_sig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {129931 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 246
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {229517 ps}
