BOARD ?= orangecrab
TOOLCHAIN ?= trellis
BUILD_DIR ?= build
PROJECT_NAME ?= twpm-puf
ARB_PUF ?= no

TOP = top
NEORV32_DIR = neorv32
SRC = top.v
NEORV32_WRAPPER = neorv32_wrapper.vhd

NEXTPNR_ARGS = --seed 1 --top $(TOP) --json $(BUILD_DIR)/$(PROJECT_NAME).json --textcfg $(BUILD_DIR)/nextpnr.config \
	--write $(BUILD_DIR)/$(PROJECT_NAME)_nextpnr.json
NEORV32_SRC = $(filter-out %neorv32_cfs.vhd, \
	      $(filter-out %neorv32_application_image.vhd, \
	      $(filter-out %neorv32_bootloader_image.vhd, $(wildcard $(NEORV32_DIR)/rtl/core/*.vhd) $(wildcard $(NEORV32_DIR)/rtl/core/mem/*.vhd)))) \
	fpga_puf/rtl/fpga_puf.vhd \
	fpga_puf/rtl/neorv32_cfs.vhd


ifeq ($(BOARD),orangecrab)
NEXTPNR_ARGS += --25k --lpf orangecrab.lpf --package CSFBGA285 --ignore-loops --freq 48.0
ifeq ($(TOOLCHAIN),trellis)
LPF_FILE = orangecrab_diamond.lpf
else ifeq ($(TOOLCHAIN),diamond)
LPF_FILE = orangecrab.lpf
endif

ifeq ($(ARB_PUF),yes)
SRC += arbpuf/arbiter.v arbpuf/mux2x1.v arbpuf/puf.v arbpuf/switch.v
DEFINES += -DUSE_ARB_PUF
endif

NEORV32_APPLICATION = fpga_puf/sw/neorv32_application_image.vhd
NEORV32_APPLICATION = neorv32/rtl/core/neorv32_application_image.vhd
NEORV32_APPLICATION_FLAGS = \
	-Wl,--defsym,__neorv32_ram_size=32k \
	-Wl,--defsym,__neorv32_rom_size=32k

NEORV32_BOOTLOADER = neorv32/sw/bootloader/neorv32_bootloader_image.vhd

# Silence warnings about logic loops in PUF module.
YOSYS_ARGS += -w "logic loop in .*io_system_neorv32_cfs_inst_true_neorv32_cfs_inst"
endif

all: $(BUILD_DIR)/$(PROJECT_NAME).dfu

clean:
	@rm -rf $(BUILD_DIR)
	@$(MAKE) -C neorv32/sw/bootloader clean
	@$(MAKE) -C fpga_puf/sw NEORV32_HOME=$(shell pwd)/neorv32 clean
	@rm -f neorv32/sw/image_gen/image_gen
	@find neorv32/sw -name '*.o' -exec rm '{}' \;

$(BUILD_DIR):
	@mkdir -p $@

$(BUILD_DIR)/neorv32: $(BUILD_DIR)
	@mkdir -p $@

fpga_puf/sw/neorv32_exe.bin: force
	@$(MAKE) -C fpga_puf/sw NEORV32_HOME=$(shell pwd)/neorv32 clean exe USER_FLAGS="$(NEORV32_APPLICATION_FLAGS)"

fpga_puf/sw/neorv32_application_image.vhd: force
	@$(MAKE) -C fpga_puf/sw NEORV32_HOME=$(shell pwd)/neorv32 clean image USER_FLAGS="$(NEORV32_APPLICATION_FLAGS)"


$(NEORV32_BOOTLOADER): force
	@$(MAKE) -C neorv32/sw/bootloader bl_image USER_FLAGS="$(NEORV32_BOOTLOADER_ARGS)"
force: ;

ifeq ($(TOOLCHAIN),trellis)
$(BUILD_DIR)/neorv32.v: $(BUILD_DIR)/neorv32 $(NEORV32_SRC) $(NEORV32_BOOTLOADER) $(NEORV32_APPLICATION) $(NEORV32_WRAPPER)
	@ghdl -i --std=08 --work=neorv32 --workdir=$(BUILD_DIR)/neorv32 -Pbuild $(NEORV32_SRC) $(NEORV32_WRAPPER) $(NEORV32_BOOTLOADER) $(NEORV32_APPLICATION)
	@ghdl -m --std=08 --work=neorv32 --workdir=$(BUILD_DIR)/neorv32 neorv32_wrapper
	@ghdl synth --latches --std=08 --work=neorv32 --workdir=$(BUILD_DIR)/neorv32 -Pbuild --out=verilog neorv32_wrapper > $@

$(BUILD_DIR)/build.ys $(BUILD_DIR)/$(PROJECT_NAME).json $(BUILD_DIR)/$(PROJECT_NAME)_synth.v: $(SRC) $(BUILD_DIR)/neorv32.v
	@rm -f $@ $(BUILD_DIR)/build.ys
	@echo "read_verilog $^" >> $(BUILD_DIR)/build.ys
	@echo "synth_ecp5 -top $(TOP)" >> $(BUILD_DIR)/build.ys
	@echo "write_verilog $(BUILD_DIR)/$(PROJECT_NAME)_synth.v" >> $(BUILD_DIR)/build.ys
	@echo "write_json $(BUILD_DIR)/$(PROJECT_NAME).json" >> $(BUILD_DIR)/build.ys
	@yosys $(YOSYS_ARGS) $(DEFINES) $(BUILD_DIR)/build.ys |& tee $(BUILD_DIR)/yosys.log

$(BUILD_DIR)/nextpnr.config: $(BUILD_DIR)/$(PROJECT_NAME).json $(LPF_FILE)
	@nextpnr-ecp5 $(NEXTPNR_ARGS) |& tee $(BUILD_DIR)/nextpnr.log

$(BUILD_DIR)/$(PROJECT_NAME).bit: $(BUILD_DIR)/nextpnr.config
	@ecppack  --bootaddr 0   --compress $< --svf $(BUILD_DIR)/$(PROJECT_NAME).svf --bit $@
else ifeq ($(TOOLCHAIN),diamond)
$(BUILD_DIR)/build.tcl: $(BUILD_DIR) $(NEORV32_SRC) $(NEORV32_WRAPPER) $(NEORV32_BOOTLOADER) $(NEORV32_APPLICATION)
	@echo "prj_project new -name $(PROJECT_NAME) -impl $(BOARD) -dev LFE5U-25F-8MG285C -synthesis synplify" > $@
	@for file in $(SRC); do \
		echo "prj_src add -work $(PROJECT_NAME) $$(readlink -f $$file)" >> $@; done
	@for file in $(NEORV32_SRC); do \
		echo "prj_src add -work neorv32 $$(readlink -f $$file)" >> $@; done
	@echo "prj_src add -work neorv32 $$(readlink -f $(NEORV32_BOOTLOADER))" >> $@
	@echo "prj_src add -work neorv32 $$(readlink -f $(NEORV32_APPLICATION))" >> $@
	@for file in $$(readlink -f $(NEORV32_WRAPPER)); do \
		echo "prj_src add -work $(PROJECT_NAME) $$file" >> $@; done
	@echo "prj_impl option top $(TOP)" >> $@
# Save project file so that it can be opened using Diamond's GUI
	@echo "prj_project save" >> $@
	@echo "prj_run Synthesis -impl $(BOARD)" >> $@
	@echo "prj_run Translate -impl $(BOARD)" >> $@
	@echo "prj_run Map -impl $(BOARD)" >> $@
	@echo "prj_run PAR -impl $(BOARD)" >> $@
	@echo "prj_run Export -impl $(BOARD) -task Bitgen" >> $@


$(BUILD_DIR)/$(PROJECT_NAME).bit: $(BUILD_DIR)/build.tcl $(LPF_FILE)
	@cp $(LPF_FILE) $(BUILD_DIR)/$(PROJECT_NAME).lpf
	@(cd $(BUILD_DIR) && diamondc build.tcl)
	@cp $(BUILD_DIR)/$(BOARD)/$(PROJECT_NAME)_$(BOARD).bit $@
else
$(error Unsupported toolchain "$(TOOLCHAIN)")
endif

$(BUILD_DIR)/$(PROJECT_NAME).dfu: $(BUILD_DIR)/$(PROJECT_NAME).bit fpga_puf/sw/neorv32_exe.bin
	@cp $< $@.temp
	@dfu-suffix -v 1209 -p 5bf0 -a $@.temp
	@mv $@.temp $@
