IR3-回填技术
---
![](img/lec5/43.png)

1. B 还不知道S.next的**指令地址**,如何跳转?
2. 再扫描一遍中间代码,将标号替换成指令(相对) 地址
3. 可否在生成中间代码的时候就填入指令地址?

> 子节点挖坑、祖先节点填坑

4. 目前的方法是通过一边扫描得到包含Label的中间代码，然后我们可以通过再次扫描一遍中间代码来生成每一个Label的指令地址，我们的目标是一次扫描完成了上述的两部分工作。
5. 比如`if (B) S`：这时候我们得到的是`L: goto B.false`，我们替换为指令地址，则为`100: goto ___`，并且放入`B.false`中，然后向上传递，直到一个有父节点指导目标位置，然后填充进去即可。

# 1. 针对布尔表达式的回填技术
![](img/lec5/44.png)

> M的作用是得到$B_2$这段代码的第一条指令地址。

1. 综合属性B.truelist 保存需要跳转到B.true 的指令地址

![](img/lec5/45.png)

2. 综合属性B.f alselist 保存需要跳转到B.f alse 的指令地址
3. 是个数组

![](img/lec5/46.png)

![](img/lec5/47.png)

$$
\begin{aligned}
  &100: if\ E_1\ rel\ E_2\ goto\ \_ \\
  &101:\qquad goto\ \_ \\
\end{aligned}
$$

> 注意100和101指令对应nextinstr

![](img/lec5/48.png)

![](img/lec5/49.png)

> 1. 回填：$backpatch$函数，$M.instr$代表的是M的第一个地址，也就是我们要将$B_1.truelist$中的所有的坑都填为$M.instr$
> 2. $nextinstr$代表的是计数器+1

![](img/lec5/50.png)

# 2. 例子
> x < 100 || x > 200 && x != y

![](img/lec5/51.png)
![](img/lec5/52.png)

# 3. 具体语句使用填坑技术的生成式
![](img/lec5/53.png)

## 3.1. if/else控制流语句翻译
![](img/lec5/54.png)
![](img/lec5/55.png)

## 3.2. while控制流语句翻译
![](img/lec5/56.png)

> 注意N的跳转位置和next属性
> nextinstr：是生成的过程中的地址的计数器，表示的是gen("goto _")的地址

## 3.3. 不包含跳转的语句翻译
![](img/lec5/57.png)

## 3.4. switch语句翻译
![](img/lec5/58.png)
![](img/lec5/59.png)

> switch-case先把标签生成好

![](img/lec5/60.png)
![](img/lec5/61.png)

# 4. 函数/过程的中间代码翻译
![](img/lec5/62.png)

## 4.1. 新增文法以支持函数定义与调用
![](img/lec5/63.png)

## 4.2. 函数定义
![](img/lec5/64.png)

1. 函数名id放入当前符号表,建立新的符号表,处理形参F与函数体S

## 4.3. 函数调用
![](img/lec5/65.png)
![](img/lec5/66.png)
![](img/lec5/67.png)

> 集中生成param指令,代码更紧凑
