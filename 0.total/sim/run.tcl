.main clear

if {[file exists work]} {
    vdel -lib work -all
}

vlib work

vlog -sv -f filelist.f

vsim  work.top_tb

view wave
add wave -divider "TOP"
add wave -r /top_tb/*

#add wave -divider "DUT"
#add wave -r /top_tb/dut/*

run -all