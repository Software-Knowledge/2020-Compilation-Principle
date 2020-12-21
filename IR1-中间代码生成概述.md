IR1-中间代码生成概述
---

![](img/lec5/1.png)

# 1. Intermediate Representation (IR)
![](img/lec5/2.png)

1. 精确:不能丢失源程序的信息
2. 独立:不依赖特定的源语言与目标语言(如,没有复杂的寻址方式)
3. 图(抽象语法树)、三地址代码、C语言

# 2. 表达式的有向无环图
![](img/lec5/3.png)
![](img/lec5/4.png)

1. 在创建节点之前,先判断是否已存在(哈希表)

![](img/lec5/5.png)

# 3. Definition (三地址代码(Three-Address Code (TAC; 3AC)))
> 每个TAC指令最多包含三个操作数。

![](img/lec5/6.png)
![](img/lec5/7.png)
![](img/lec5/8.png)

- do i = i + 1;while(a[i] < v);

![](img/lec5/9.png)

# 4. 三地址代码的四元式表示

## 4.1. Definition (四元式(Quadruple))
> 一个四元式包含四个字段,分别为op、arg1、arg2与result。

![](img/lec5/10.png)

![](img/lec5/11.png)

