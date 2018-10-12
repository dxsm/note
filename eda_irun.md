# EDA工具使用

## cadence irun命令
### 常用编译
`irun +access+wr -smartorder -clean -ntcnotchks -V93 -vtimescale 1ns/1ps -work chip_lib -f xxx.vc -top tb_top -64`

### coverage选项
`-covtest xxx -coverage all -covoverwrite -covfile covfile.ccf -covworkdir ./cov_work`
其中*covfile.ccf*定义coverage内容
```tcl
set_expr_scoring -all
set_fsm_scoring -hold_tansition
set_libcell_scoring
set_implicit_block_scoring -off
set_covergroup -per_instance_default_one

select_coverage -all -instance tb_top.xxx*...
```

## Synopsys Verdi
```shell
vhdlcom -v93 -sup_sem_error -smartorder -work chip_lib -f vhdl.flist
vericom -sv +systemverilogext+sv +v95ext+v95 +verilog2001ext+v -ignorekwd_config -work chip_lib -f verilog.flist
verdi -lib chip_lib -top xxx -ssf xxx.fsdb
```

## cadence imc命令
coverage merge:
`imc -exec cov_merge.tcl`

其中cov_merge.tcl如下：
```tcl
merge -runfile runfile -metrics code:fsm:block:expression:toggle:assertion:covergroup -out merge_data -overwrite -message 1 -initial_model union_all
load -run merge_data
report -detail -html -showempty on -overwrite -grading covered -source on -out nc_cov_report
```

其中runfile列出需要merge的coverage路径
```
./cov_work/scope/case1
./cov_work/scope/case2
./cov_work/scope/case3*
```
