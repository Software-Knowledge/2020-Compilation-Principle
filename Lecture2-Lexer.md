Lecture2-Lexer
---
> 词法分析

# 1. 输入和输出

1. 输入:程序文本/字符串s和**词法单元(token)的规约**
2. 输出:词法单元流

![](img/lec2/1.png)

## 1.1. 词法表示形式
`token: <token-class, attribute-value>`

| 词法单元    | 非正式描述                       | 词素示例      |
| ----------- | -------------------------------- | ------------- |
| if          | 字符i、f                         | if            |
| else        | 字符e、l、s、e                   | else          |
| comparision | < 或 > 或 <= 或 >= 或 == 或 !=   | <= , !=       |
| id          | 字符开头的字母/字符串            | pi, score, D2 |
| number      | 任何字符常量                     | 3.14          |
| literal     | 在两个"之间，处理"以外的任何字符 | "core dumped" |

- int/if:关键词
- ws:空格、制表符、换行符
- comment:“//” 开头的一行注释或者“/* */” 包围的多行注释

## 1.2. 词法分析示例
```c++
int main(void){
  printf("hello, world\n")
}
```

> 词法分析的结果：本质上，就是一个**字符串(匹配/识别)**算法

```
int ws main/id LP void RP ws
LB ws
ws id LP literal RP SC ws
RB
```

# 2. 词法分析器的三种设计方法
> 生产环境下的编译器(如gcc) 通常选择手写词法分析器

1. 手写词法分析器
2. 词法分析器的生成器
3. 自动化词法分析器

- flex是自动的词法分析器
- 词法分析器相对比较简单，手写词法分析器可以做一些人为的优化。
- gcc中，c语言的lex是1400多行，而c++的lex则是4000多行代码，number是最复杂的，包含不同进制、字母等问题，课程与gcc有一定差异

## 2.1. 手写词法分析器
1. 识别字符串s中符合**某种词法单元模式**的**所有词素**

```c++
if ab42 >= 3.14:
  xyz := 2.99792458E8
else
  xyz := 2.718
  abc := 1024
```

> 这里的分割不适宜使用空格，例如`ab42>=42`则空格分割不出来。

```
ws if else id integer
relop(关系运算符)
real sci(识别实数，带科学技术发和不带的)
assign(:=)
```

1. 识别字符串s中**词素某种词法单元模式**的**前缀词素**
2. 识别字符串s中**符合特定词法单元模式**的**前缀词素**(例如识别符合id的模式的开头的第一个词素)
3. 注意：这里的第一个词素就只看第一个，而不是找到符合要求的第一个
4. 最重要的是状态转移图

### 2.1.1. 分支与判断
1. 识别字符串s中符合特定词法单元模式的前缀词素

> 分支:先判断属于哪一类, 然后进入特定词法单元的前缀词素匹配流程

2. 识别字符串s中符合某种词法单元模式的前缀词素

> 循环:返回当前识别出来的词法单元与词素, 继续识别下一个前缀词素

3. 识别字符串s中符合某种词法单元模式的所有词素

```
先: ws if else id integer
然后: relop
最后: real sci
留给大家: assign (:=)
```

### 2.1.2. 识别字符串s中符合**特定词法单元模式**的**开头第一个词素**
```java
public int line = 1;
private char peek = " ";
private Hashable words = new Hashtable();
```

1. line:行号, 用于调试
2. peek:**下一个向前看字符(Lookahead)**
3. words:**从词素到词法单元标识符或关键词的映射表**

```
// 先将关键字方进去
words.put("if", if)
words.put("else", else)
```

#### 2.1.2.1. 识别空格，不做处理
```
ws: blank tab newline
```

```java
// 识别空白部分，并忽略之
public Token scan() throws IOException{
  for(;;peek=(char)System.in.read()){
    if(peek == " " || peek == "\t") continue;
    else if(peek == "\n") line = line + 1;
    else break;
  }
}
```

```java
peek = next input char acter ;
while ( peek != null) {
  //if peek is not a ws, break
  peek = next input char acter
}
// 这样子写，可以吗？这样子是不可以的，因为在最后合并的时候会出现问题。
```

1. char peek = " ":下一个向前看字符
2. 例子:`123abc`，得到`<number, 123>`和`<id, abc>`
3. 注意上文中123读取完了之后跳出的是a位置，不能入上面第二个部分，不然会丢东西。

![](img/lec2/2.png)

> 1. 上图数字没有含义
> 2. 重要是，当前识别的出的空白符**不包含**当前peek指向的字符
> 3. 22：碰到other怎么办？
> 4. 上图中的*表示，必须是当前的词开始。

#### 2.1.2.2. **integer**: 整数(允许以0开头)

```java
if( Character.isDigit(peek) ) {
  int V = 0;
  do {
    v = 10 * v + Character.digit(peek, 10);
    peek = (char)System.in.read();
  }while(Character.isDigit(peek));
  return new Num(v);
}
```

![](img/lec2/18.png)

> 12:碰到other如何处理？
> 补充图片如下

![](img/lec2/3.png)

#### 2.1.2.3. id: 字母开头的字母/数字串

```java
if(Character.isLetter(peek) ) {
  StringBuffer b = new StringBuffer() ;
  do {
    b.append(peek);
    peek = (char)System.in.read();
  }while(Character.isLetter0rDigit(peek));
  String s = b.toString();
  // 从表中检查关键字或已识别的标识符，看有无
  Word W = (Word)words.get(s);|
  if(w != null) return w;
  // 如果是未识别的标识符，则加入几区
  w = new Word(Tag.ID, s) ;
  words.put(s, w) ;
  return w;
}
```

- 识别词素、**判断是否是预留的关键字或已识别的标识符**、保存该标识符

![](img/lec2/4.png)

> 9:碰到other怎么处理?

#### 2.1.2.4. 遇到other情况的处理(也就是处理错误)
```java
Token t = new Token(peek);
peek = " ";
return t;
```

> 错误处理模块:出现**词法错误**, 直接报告异常字符

#### 2.1.2.5. SCAN()前缀词素处理
![](img/lec2/19.png)

1. **关键点**:合并22, 12, 9, 根据**下一个字符**即可判定词法单元的类型
2. 否则, 调用错误处理模块(对应other), 报告**该字符有误**, 并忽略该字符

#### 2.1.2.6. 合并词法分析器
```java
package lexer; //文件Lexer.java
import java.io.*;
import java.util.*;

public class Lexer {

  public lnt llne = 1 ;
  private char peek = " ";
  private Hashtable words = new Hashtable();

  void reserve(Word t) { words.put(t.lexeme, t);}

  public Lexer() {
    reserve(new Word(Tag.TRUE, "true"));
    reserve(new Word(Tag.FALSE, "false"));
  }
  public Token scan() throws I0Exception {
    //ws
    for(;; peek = (char)System.in.read()) {
      if( peek == " "| | peek == '\t') continue ;
      else if( peek == '\n' ) line = line + 1;
      else break ;
    }
    //digit
    if(Character.isDigit(peek)){
      int v=0;
      do{
        v = 10 * v + Character.digit(peek, 10) ;
        peek = (char)System.in.read();
      } while(Character.isDigit(peek));
      return new Num(v);
    }
    //letter
    if(Char acter.isLetter(peek)) {
      StringBuffer b = new StringBuffer();
      do{
        b.append(peek);
        peek = (char)System.in.read() ;
      }while(Character.isLetter0rDigit(peek));
      String s = b.toString();
      Word w = (Word)words.get(s);
      if( w != null ) return w;
      w = new Word(Tag.ID, s);
      words.put(s，w);
      return w;
    }
    // error
    Token t= new Token(peek) ;
    peek = " ";
    return t;
  }
}
```

1. 外层**循环**调用**scan()**(不考虑语法分析)
2. 或者由语法分析器**按需**调用**scan()**，语法分析器每次从词法分析器中提取到下一个token，检查是不是自己想要的下一个词。

![](img/lec2/7.png)

> 回溯之前的问题

#### 2.1.2.7. 处理关系运算符
> relop: < > <= >= == <>

![](img/lec2/5.png)

1. 最长优先原则: 例如, 识别出<=, 而不是< 与=
2. 注意：此处的=是判断是否相等的关系运算符。如果=表示赋值，而==表示判断，如何设置词法分析器
3. 问题：0的时候遇到other如何处理？

#### 2.1.2.8. 再次合并
![](img/lec2/6.png)

1. 关键点: 合并22, 12, 9, 0, 根据**下一个字符**即可判定词法单元的类型
2. 否则, 调用错误处理模块(对应other), 报告**该字符有误**, 并忽略该字符

### 2.1.3. 更复杂的词法分析器：识别数字
1. 我们可以类似关系运算符来识别各种数字吗？比如将real、sci分开识别，然后合并会有什么问题？
2. `ws if else id integer relop`
3. 前一个词法分析器的前提如下(而现在并不满足这样子)
   1. 根据**下一个字符**即可判定词法单元的类型
   2. 每个状态转移图的每个状态要么是**接受状态**, 要么带有**other 边**
4. 问题:如何同时识别real和sci

![](img/lec2/20.png)

> 1. 上图中主要展示了正确的流程
> 2. 我们可以认识到，看任意个字符我们都无法确定到底进入哪一个，这也就解释了为什么我们不可以类似关系运算符来确定状态。
> 3. 双圈表示接受状态

5. 可以同时识别的real和sci的状态图

![](img/lec2/21.png)

> 1. 12 : 碰到other 怎么办?尝试其它词法单元或进入错误处理模块
> 2. 14, 16, 17 : 碰到other 怎么办?回退, 寻找最长匹配，peek指针也要回退
> 3. 我们允许合并后的状态转换图尽量读取输入，直到不存在下一个状态为止，然后类似上面所讨论的那样取最长的和某个模式匹配的最长词素。
> 4. 例如1.2345E+a -> 1.2345 E + a，gcc会直接认为这个字符串是非法的，而我们的词法分析器在词法部分不这么认为(也就是完成划分)，也就是在语法阶段拒绝。

### 2.1.4. 最终的词法分析器
![](img/lec2/22.png)

1. **关键点**: 合并22, 12, 9, 0, 根据**下一个字符**即可判定词法单元的类型
2. 否则, 调用错误处理模块(对应other), 报告**该字符有误**, 忽略该字符。
3. 注意, 在sci中, 有时需要**回退**, 寻找最长匹配。

## 2.2. Flex(词法分析器的生成器)
> Fast Lexical Analyzer Generator

![](img/lec2/23.png)

### 2.2.1. 获取词法单元流
1. **输入**: 程序文本/字符串s & 词法单元的规约
2. **输出**: 词法单元流

![](img/lec2/8.png)

### 2.2.2. 词法分析器的获得
1. **输入**: 词法单元的规约
2. **输出**: 词法分析器
3. 比较关键的是`.l`文件

![](img/lec2/9.png)

### 2.2.3. 词法单元的规约
1. 我们需要词法单元的形式化规约

![](img/lec2/10.png)

> 我们需要词法单元的**形式化**规约

1. **id**: 字母开头的字母/数字串
2. **id**定义了一个集合, 我们称之为**语言(Language)**，C语言就是使用C语言写出来的所有语言
3. 它使用了字母与数字等符号集合, 我们称之为**字母表(Alphabet)**
4. 该语言中的每个元素(即, 标识符) 称为**串(String)**

### 2.2.4. Definition (字母表)
1. 字母表$\Sigma$是一个有限的符号集合。

### 2.2.5. Definition (串)
1. 字母表$\Sigma$上的串(s)是由$\Sigma$中符号构成的一个**有穷**序列。
2. 空串:$|\epsilon| = 0$

#### 2.2.5.1. Definition (串上的“连接” 运算)
1. x = dog, y = house xy = doghouse
2. $s \epsilon = \epsilon s = s$

#### 2.2.5.2. Definition (串上的“指数” 运算)
1. $s^0 \triangleq ϵ$
2. $s^i \triangleq ss^{i-1}, i>0$

### 2.2.6. Definition (语言)
1. **语言**是给定字母表$\Sigma$上一个任意的**可数**的串集合。

$$
\emptyset \\
{\epsilon} \\
id : {a, b, c, a1, a2, . . . } \\
ws : {blank, tab, newline} \\
if : {if} \\
$$

1. 语言是串的集合，所以所有和集合相关的都可以在语言上操作。
2. 因此, 我们可以通过集合操作**构造**新的语言。

### 2.2.7. 语言上的计算
![](img/lec2/11.png)

1. 后两项显著增强了语言的能力，Kleene闭包是$L*$，正闭包是$L+$
2. L*允许我们构造**无穷**集合

$$
L = {A,B, . . . ,Z, a, b, . . . , z} \\
D = {0, 1, . . . , 9} \\
L\cup D 并集\\
LD 520个元素\\
L^4 长度为4的字母串\\
L^* 所有子母串\\ 
D^+ 非空数字串\\ 
L(L\cup D)^∗ 标识符 \\
id : L(L \cup D)^∗ \\
$$

## 2.3. 正则表达式
1. 每个正则表达式r 对应一个正则语言L(r)
2. 正则表达式是**语法**, 正则语言是**语义**

### 2.3.1. 定义
1. 给定字母表$\Sigma$, $\Sigma$上的正则表达式**由且仅由**以下规则定义:
   1. $\epsilon$是正则表达式;
   2. $\forall a \in \Sigma$，a是正则表达式;
   3. 如果r是正则表达式, 则(r)是正则表达式;
   4. 如果r与s是正则表达式, 则r|s, rs, r∗ 也是正则表达式(这是语法部分)
2. 运算优先级:$() > * > 连接 > |$
3. $(a)|((b)*(c))\equiv a|b*c$
4. 正则表达式对应的正则语言

$$
L(\epsilon) = {\epsilon} (1)\\
L(a) = {a}, \forall a \in \Sigma (2)\\
L((r)) = L(r) (3)\\
L(r|s) = L(r) \cup L(s) \ L(rs) = L(r)L(s) \ L(r*) =(L(r))* (4)\\
$$

> 示例

$$
\Sigma = {a, b} \\
L(a|b) = {a, b} \\
L((a|b)(a|b)) = {aa, ab, ba, bb} \\
L(a*) = (L(a))* = {a}* = {\emptyset, a , aa, ...}\\
前一个*是正则表达式上的，后一个*是闭包
L((a|b)*) = (L(a, b))*\\
L(a|a*b) = {a, b, ab, aab, ...}\\
$$

### 2.3.2. 词法分析
![](img/lec2/12.png)
![](img/lec2/13.png)

1. 其他常用的:
   1. `[^s]`:表示不在这个s中的任意一个字符
   2. `^`:外面的尖括号，表示行首
   3. `$`:表示结尾
   4. `.`:除了换行符以外的
   5. `\c`:字符自免租

### 2.3.3. 正则表达式示例
| ![](img/lec2/14.png) | ![](img/lec2/15.png) |
| -------------------- | -------------------- |
| ![](img/lec2/16.png) | ![](img/lec2/17.png) |

![](img/lec2/24.png)

> $(0|1(01*0)1))*$：匹配3的倍数
> <a href = "https://regex101.com/r/ED4qgC/1">正则表达式</a>

![](img/lec2/25.png)

### 2.3.4. Flex程序的结构(.l文件)
1. **声明部分**: 直接拷贝到.c 文件中
2. **转换规则**: **正则表达式{动作}**
3. **辅助函数**: 动作中使用的辅助函数

```
声明部分
%%
转换规则
%%
辅助函数
```

![](img/lec2/26.png)

1. 最上面我们使用的标准库(原封不动拷贝到lex.yy.c中)
2. 第三部分没有用到
3. 声明部分是可以互相引用的:通过`{}`来实现、
4. 动作中调用的函数可以在辅助部分使用
5. `yytext`是哪里来的呢？flex背后做了很多的事情，需要告诉你做了什么，`yytext`是flex暴露的全局变量，表示获取到的词素。

```sh
flex lexical.l // 生成.yy.c文件
cc lex.yy.c -lfl -o lexical.out // 使用cc进行编译，-lfl表示需要调用一些库
./lexical-out // 执行
```

### 2.3.5. Flex 中两大**冲突解决**规则
1. 最前优先匹配: 关键字vs. 标识符
2. 最长优先匹配: >=, ifhappy, thenext, 1.23

![](img/lec2/26.png)

### 2.3.6. 目标: 正则表达式RE => 词法分析器
![](img/lec2/27.png)

> 终点固然令人向往, 这一路上的风景更是美不胜收