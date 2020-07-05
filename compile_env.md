---
title: 搭建irun编译与起verdi小环境
date: 2019-05-04 22:30:02
tags: [eda_tools, ASIC]
category: eda_tools
---

## 1. 小环境makefile模板
```makefile
design = tb
verilog_flist = -f ./test.vc tb.v
vhd_flist =
wave = wave.fsdb

#whether to open verdi wave gui
ifdef wave
	verdi_cmd += -ssf $(wave)
endif

.PHONY: help clean ius compile verdi

help:
	@echo "#==============================================================="
	@echo "# [Info] make help    : show help infomation"   
	@echo "# [Info] make clean   : clean ius and verdi compile library,log"   
	@echo "# [Info] make compile : compile for verdi"   
	@echo "# [Info] make verdi   : raise verdi gui"   
	@echo "#==============================================================="

clean:
	@rm chip_lib.lib++ work.lib++ INCA_libs verdiLog vericomLog vhdlcomLog -rf

ius:
	irun +access+wr -smartorder -clean -ntcnotchks -V93 -vtimescale 1ns/1ps +define+RD=1 -work chip_lib $(verilog_flist) $(vhd_flist) -top $(design) -64bit

compile:
ifdef vhdl_flist
	vhdlcom -V93 -sup_sem_error -smartorder -work chip_lib $(vhdl_flist)
endif
ifdef verilog_flist
	vericom -sv +systemverilog+sv +v95ext+v95 +verilog2001ext+v -ignorekwd_config +define+RD=1  -work chip_lib $(verilog_flist)
endif

verdi:compile
	verdi -lib chip_lib $(verdi_cmd) &
```

<!-- more -->
