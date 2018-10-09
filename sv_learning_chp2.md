# systemverilog任务、函数、program

* 缺省情况下参数的类型是与其前一个参数相同的，而第一个参数的缺省类型是logic单bit输入
* 参数的传递方式可以使用ref指定为引用，通常用于数组引用；当不希望子程序改变数组值时，可以使用const ref类型
* ref参数只能被用于带自动存储(automatic)的子程序中，即使用ref参数时子程序必须指明automatic属性
* 自动存储相对的是静态存储，当多个地方调用静态存储子程序时，不同的线程之间会窜用这些局部变量，而自动存储能够迫使仿真器使用堆栈存储局部变量
* 函数使用return返回一个值，调用时可以使用void忽略返回值，例如`void'($fscanf(file,"%d",i));`

```verilog{.line-numbers}
module test_func();

int arr[];

//************************************
// operator = "+", return a.sum
// operator = "x", return a.product
//************************************
function automatic int alu(
    const ref int a[],           //数组引用,const不能改变数组
    input string operator = "+"  //指定default值
);

int result;

if(operator=="x") begin
  result = 1;
  for(a[i])
    result *= a[i];
end
else begin
  result = 0;
  for(a[i])
    result += a[i];
end

return result;
endfunction

initial begin
  arr = new[5];
  arr = '{1,2,3,4,5};
  $display(alu(arr));    //15, use default operator
  $display(alu(arr,"x")) //120
end

endmodule
```

## program
**program与module相同点**
* 和module相同，program也可以定义0个或多个输入、输出、双向端口。
* 一个program块内部可以包含0个或多个initial块、generate块、specparam语句、连续赋值语句、并发断言、timeunit声明。
* 在program块中数据类型、数据声明、函数和任务的定义均与module块类似。
* 一个设计中可以包含多个program块，这些program块既可以通过端口交互，也可以相互独立，这一点与module块也是相似的。

**program与module不同点**
* 一个program块不能包含任何always块，用户自定义原语(UDP)，module块、接口(interface)、program块
* module中可以定义program块
* 一个program块可以调用其他module块或者program块中定义的函数或任务，但是一个module块却不能调用其他program块中定义的任务或函数。
* program块中变量只能用阻塞赋值，不能使用非阻塞赋值
