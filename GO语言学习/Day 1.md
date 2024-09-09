# 1. Hello World

首先创建文件hello.go

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello,World!")
}
```

然后执行

```bash
go run hello.go
```

可以看到

```shell
Hello,World
```

或者使用

```bash
go build hello.go
```

这会生成一个二进制程序,之后执行

```bash
./hello
```

也可以看到

```shell
Hello,World
```

# 2. 变量定义

```go
package main
import "fmt"

// 全局变量
var l = 2

func main(){
	// 变量定义
	var a int
	var b int
	// 类型推导
	var c = 1
  var d = "LOL"
	// 简短变量声明,仅可在函数内部使用
	e := 1
	f := "LOL"
	// 多变量声明
	var g, h int
	var i, j = 1, 2
	k, l := 1, 2
	// 匿名变量
	_, m := 1, 2
	// 常量
	const n = 1
	// 输出
	fmt.Println(a, b, c, d, e, f, g, h, i, j, k, l, m, n)
}
```

# 3. iota

iota 在 const关键字出现时将被重置为 0(const 内部的第一行之前)，const 中每新增一行常量声明将使 iota 计数一次(iota 可理解为 const 语句块中的行索引)。

```go
package main

import "fmt"

func main() {
	const (
		a = iota // a = 0
		b        // b = 1
		c        // c = 2
	)
	fmt.Println(a, b, c)
	e := 233
	f := 233
	const (
		g = iota // g = 0
		h        // h = 1
	)
	fmt.Println(e, f, g, h)
}
```

# 4. select

select 是 Go 中的一个控制结构，类似于 switch 语句。

select 语句只能用于通道操作，每个 case 必须是一个通道操作，要么是发送要么是接收。

select 语句会监听所有指定的通道上的操作，一旦其中一个通道准备好就会执行相应的代码块。

如果多个通道都准备好，那么 select 语句会随机选择一个通道执行。如果所有通道都没有准备好，那么执行 default 块中的代码。

以下是一个例子

```go
select {
  case <- channel1:
    // 执行的代码
  case value := <- channel2:
    // 执行的代码
  case channel3 <- value:
    // 执行的代码

    // 你可以定义任意数量的 case

  default:
    // 所有通道都没有准备好，执行的代码
}
```

以下描述了 select 语句的语法：

- 每个 case 都必须是一个通道

- 所有 channel 表达式都会被求值

- 所有被发送的表达式都会被求值

- 如果任意某个通道可以进行，它就执行，其他被忽略。

- 如果有多个 case 都可以运行，select 会随机公平地选出一个执行，其他不会执行。

否则：

- 如果有 default 子句，则执行该语句。
- 如果没有 default 子句，select 将阻塞，直到某个通道可以运行；Go 不会重新对 channel 或值进行求值。

以下实例执行后会不断地从两个通道中获取到的数据，当两个通道都没有可用的数据时，会输出 "no message received"。

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// 定义两个通道
	ch1 := make(chan string)
	ch2 := make(chan string)

	// 启动两个 goroutine，分别从两个通道中获取数据
	go func() {
		for {
			time.Sleep(1)
			ch1 <- "from 1"
		}
	}()
	go func() {
		for {
			time.Sleep(2)
			ch2 <- "from 2"
		}
	}()

	// 使用 select 语句非阻塞地从两个通道中获取数据
	for {
		time.Sleep(time.Duration(500) * time.Millisecond)
		select {
		case msg1 := <-ch1:
			fmt.Println(msg1)
		case msg2 := <-ch2:
			fmt.Println(msg2)
		default:
			// 如果两个通道都没有可用的数据，则执行这里的语句
			fmt.Println("no message received")
		}
	}
}
```

以下是一个通过通道累加到1000的代码

```go
package main

import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	var channel1 = make(chan int)
	var channel2 = make(chan int)
	var done = make(chan bool)
	var sum = 0

	go func() {
		for {
			select {
			case channel1 <- rand.Int() % 10:
			case channel2 <- rand.Int() % 10:
			}
		}
	}()

	go func() {
		for {
			select {
			case num1 := <-channel1:
				sum += num1
			case num2 := <-channel2:
				sum += num2
			case <-done:
				return
			}
			fmt.Println(sum)
			if sum >= 1000 {
				done <- true
			}
		}
	}()

	time.Sleep(1 * time.Second) // 避免忙等待
}
```

# 5. 函数定义

Go 语言函数定义格式如下：

```go
func function_name( [parameter list] ) [return_types] {
   函数体
}
```

例如，以下是一个返回两个数字中最大值的函数

```go
func Max(a, b int) int {
	if a > b {
		return a
	} else {
		return b
	}
}
```

go语言中函数也可以作为实参

```go
func main() {
	sqrt := func(x float64) float64 {
		return math.Sqrt(x)
	}
	fmt.Println(sqrt(4)) // 2
}
```

Go 语言支持匿名函数，可作为闭包。匿名函数是一个"内联"语句或表达式。匿名函数的优越性在于可以直接使用函数内的变量，不必申明。

匿名函数是一种没有函数名的函数，通常用于在函数内部定义函数，或者作为函数参数进行传递。

```go
func add(a int) func() int {
	sum := 0
	return func() int {
		sum = sum + a
		return sum
	}
}

func main() {
	ADD := add(2)
	fmt.Println(ADD()) // 2
	fmt.Println(ADD()) // 4
}
```

方法

```go
package main

import "fmt"

type Circle struct {
	radius float64
}

func area(circle Circle) float64 {
	return 3.14 * circle.radius * circle.radius
}

func main() {
	c := Circle{radius: 10}
	fmt.Println(area(c))
}
```



