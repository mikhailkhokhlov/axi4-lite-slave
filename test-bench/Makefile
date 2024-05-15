OUT      := out
WORK     := work
LOG      := compile.log
TOP      := tb
DUT      := dut
WAVES    := 1
SIM_OPTS := -gui

export OUT
export WORK
export LOG
export TOP
export DUT
export WAVES
export SIM_OPTS

#v=@

SRC_VERILOG=$(shell find . -name "*.v")
SRC_SV=$(shell find . -name "*.sv")

$(OUT)/compile.stamp: $(SRC_SV) $(SRC_VERILOG) $(OUT)
	@echo "Compile sources..."
	$(v)vlib $(OUT)/$(WORK) > $(OUT)/$(LOG)
	$(v)vmap work $(OUT)/$(WORK) >> $(OUT)/$(LOG)
	$(v)vlog -sv -work $(WORK) $(SRC_SV) $(SRC_VERILOG) >> $(OUT)/$(LOG)
	@touch $@

$(OUT):
	@echo "Create $(OUT)..."
	mkdir -p $@

sim: $(OUT)/compile.stamp
	@echo "Run simulation..."
	$(v)vsim $(SIM_OPTS) work.$(TOP) -work $(OUT)/$(WORK) -do questa.tcl \
                -voptargs="+acc" -l $(OUT)/sim.log -wlf $(OUT)/sim.wlf > $(OUT)/sim.log

default: $(OUT)/compile.stamp
	@echo "all target"

clean:
	@echo "Clean up build..."
	@rm -rvf $(OUT)

.PHONY: default clean
