# systemverilog基础

## 1. 内建数据类型
四状态：reg, wire, logic, integer, time(默认值为X)
双状态：bit, int, byte, shortint, longint, real(默认值为0)
有符号数：int, byte, shortint, longint, integer(可以使用unsigned申明为无符号数)

:fa-heart: **`$isunknown`操作符:**
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

## 2. 数组
### 2.1 数组初始化、比较、 复制、循环
循环使用for或foreach

```verilog{.line-numbers}
//test_array.sv
module test_array();

// array initial
int mem1[4] = '{1,2,3,4};
int mem2[4] = '{4{8}};    //'{8,8,8,8}
//int mem3[5] = '{9,8,default:1};  //'{9,8,1,1,1} my eda tool does not support
int arr[4][4] = '{
  '{0,1,2,3},
  '{1,2,3,4},
  '{2,3,4,5},
  '{3,4,5,6}
};

initial begin
  //array compare
  $display("mem1 %s mem2", (mem1==mem2) ? "==" : "!=");   //mem1 != mem2
  //array copy
  mem2 = mem1;
  $display("mem1 %s mem2", (mem1==mem2) ? "==" : "!=");   //mem1 == mem2

  //array loop
  $display({20{"="}}); //seperate line
  foreach(arr[i][j])
    $display("arr[%0d][%0d] = %0d", i, j, arr[i][j]);

  $display({20{"="}}); //seperate line
  foreach(arr[i]) begin
    foreach(arr[,j])
      if(j>=i)
        $write("%3d",arr[i][j]);
      else
        $write("%3s","");
    $display;
  end
end

endmodule
```
运行结果如下：
![](assets/markdown-img-paste-20180930165253739.png)

### 2.2 动态数组
* 分配空间`new[]`
* 分配空间并复制`new[](arr)`
* 释放空间`arr.delete()`
* 当数组(动态或定宽)复制给一个动态数组时，会调用构造函数new[]分配空间并复制数据
* `$size(arr)`返回数组宽度

```verilog{.line-numbers}
module dyn_array();

// declare and initial
int dyn[];
int arr[3] = '{9,7,8};

initial begin
  //分配空间
  dyn = new[5];
  foreach(dyn[i])
    dyn[i] = i;  //'{1,2,3,4,5}

  //分配空间并复制
  dyn = new[10](dyn); //'{1,2,3,4,5,0,0,0,0,0}
  dyn = arr; //'{9,7,8}

  //重新分配空间，旧值不复存在
  dyn = new[3]; //'{0,0,0}

  //释放空间
  dyn.delete();
  $display($size(dyn));  //0
end

endmodule
```

### 2.3 队列
* 声明q[\$]
* \$表示队列索引的最大值或最小值，[\$:2]代表[0:2]，[1:\$]代表[1:\$size(q)-1]，**不是所有仿真器都支持\$表示最小值**
* `q.insert(idx,value)`, 在idx之前插入元素或者队列，**不是所有仿真器都支持插入队列**
* `q.delete(idx)`, 删除第idx个元素
* `q.push_front(value)`, 在队列前面插入元素，等价于q={value,q}
* `q.push_back(value)`, 在队列末尾插入元素，等价于q={q,value}
* `q.pop_front`, 从队列前面移出元素，等价于j=q[0]; q=q[1:\$]
* `q.pop_back`, 从队列末尾移出元素，等价于j=q[\$]; q=q[0:\$-1]
* `q.delete()`, 清空队列，等价于q={}
* 可以把定宽或动态数组复制给队列
* 队列遍历也可以使用for和foreach

```verilog{.line-numbers}
module queue();

// declare and initial
int q[$] = {0,2,5};
int q1[$] = {3,4};
int arr[4] = '{9,8,7,6};
int j = 1;

initial begin
  q.insert(1,j); //{0,1,2,5}
  //q.insert(3,q1);  //{0,1,2,3,4,5}, my eda tool does not support insert queue
  q = {q[0:2],q1,q[$]}; //{0,1,2,3,4,5}, use concat instead of insert function
  q.delete(1); //{0,2,3,4,5}

  q.push_front(6); //{6,0,2,3,4,5}
  q.push_back(8);  //{6,0,2,3,4,5,8}
  j = q.pop_front; //{0,2,3,4,5,8}, j=6
  j = q.pop_back;  //{0,2,3,4,5}, j=8

  q = arr; //{9,8,7,6}, copy array to queue

  q.delete(); //empty queue
  $display("%0d", $size(q)); //0
end

endmodule
```

### 2.4 数组常用方法
* `arr.sum`, 返回数组所有元素和
* `arr.product`, 返回数组所有元素积
* `arr.and`, 返回数组所有元素的与
* `arr.or`, 返回数组所有元素的或
* `arr.xor`, 返回数组所有元素的异或
* `arr.min()`, 返回数组中的最小值队列(**注意：返回的是队列，而不是标量**)
* `arr.max()`, 返回数组中的最大值队列(**注意：返回的是队列，而不是标量**)
* `arr.unique()`, 返回数组中具有唯一值的队列
* `arr.find with (condition)`, 返回满足条件元素的队列
* `arr.find_index with (condition)`, 返回满足条件元素下标的队列
* `arr.find_first with (condition)`, 返回满足条件第一个元素的队列
* `arr.find_first_index with (condition)`, 返回满足条件第一个元素下标的队列
* `arr.find_last with (condition)`, 返回满足条件第最后一个元素的队列
* `arr.find_last_index with (condition)`, 返回满足条件最后一个元素下标的队列
* `arr.reverse()`, 数组反向
* `arr.sort()`, 数组从小到大排序
* `arr.rsort()`, 数组从大到小排序
* `arr.shuffle()`, 数组打乱顺序
* 其中`reverse`和`shuffle`方法不能带with条件语句，它们的作用范围是整个数组

```verilog{.line-numbers}
module array();

int arr[] = '{9,1,8,6,3,4,6,11,4};
int q[$];

initial begin
  //reduce operator(return value)
  $display(arr.sum);      //52
  $display(arr.product);  //1368576
  $display(arr.and);      //0
  $display(arr.or);       //15
  $display(arr.xor);      //8

  //min,max,unique(return queue)
  q = arr.min();    //{1}
  q = arr.max();    //{11}
  q = arr.unique(); //{9,1,8,6,3,4,11}

  //find operator(return queue)
  q = arr.find with (item>3);  //{9,8,6,4,6,11,4}
  q = arr.find_index(x) with (x>3);  //{0,2,3,5,6,7,8}, with的默认变量为item，也可以改为其他的
  q = arr.find_first with (item<4);  //{1}
  q = arr.find_first_index with (item==6);  //{3}
  q = arr.find_last with (item<4);  //{3}
  q = arr.find_last_index with (item==6);  //{6}

  //sort operator(array changed)
  arr.reverse();  //{4,11,6,4,3,6,8,1,9}
  arr.sort();     //{1,3,4,4,6,6,8,9,11}
  arr.rsort();    //{11,9,8,6,6,4,4,3,1}
  arr.shuffle();  //{9,6,3,4,4,11,6,1,8}, 不同仿真器洗牌的结果是否一致？
end

endmodule
```

## 3. 字符串
* `s.getc(N)`, 返回位置N上的字节
* `s.tolower()`, 返回所有字符小写字符串
* `s.toupper()`, 返回所有字符大写字符串
* `s.putc(N,C)`, 将字节C写到字符串的N位，N必须在0~len-1之间
* `s.substr(start,end)`, 返回从start到end之间所有字符
* `s.len()`, 返回字符串长度
* `$psprintf()`, 返回一个格式化的临时字符串，可以直接传递给其他子函数

```verilog{.line-numbers}
module test_string();

string s;

initial begin
  s = "IEeE ";
  $display("%s", s.getc(0)); //I
  $display(s.tolower());  //ieee
  s = s.toupper();  //IEEE
  s.putc(s.len()-1, "-");  //IEEE-
  s = {s, "P1800"};  //IEEE-P1800
  $display(s.substr(2,5));  //EE-P
  $display($psprintf("%s %0d",s,42));  //IEEE-P1800 42
end

endmodule
```
