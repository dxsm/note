# 数据类型

## 1. 内建数据类型
四状态：reg, wire, logic, integer, time(默认值为X)
双状态：bit, int, byte, shortint, longint, real(默认值为0)
有符号数：int, byte, shortint, longint, integer(可以使用unsigned申明为无符号数)

:fa-book: **`$isunknown`操作符:**
作用：使用`$isunknown`操作符，可以在表达式的任意位出现X或Z时返回1

```verilog{.line-numbers}
//test_isunknown.sv
module test_isunknown();

logic [3:0] din;

initial begin
  din = 4'b1001;  //Unknown not found!
  din = 4'b1x01;  //Unknown is detected!
  din = 4'b1z01;  //Unknown is detected!
  if($isunknown(din))
    $display("Unknown is detected!");
  else
    $display("Unknown not found!");
end

endmodule
```
