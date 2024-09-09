在 Go 语言的标准库中，`log` 包提供了几种不同的日志记录函数，用于记录不同级别的日志信息。`log.Panic` 和 `log.Fatal` 都是用于记录错误信息并停止程序执行的函数，但它们之间有一些细微的区别。

# 1. log.Panic

- `log.Panic` 函数会记录一条错误信息，然后调用 `panic` 函数。
- 当 `log.Panic` 被调用时，程序会立即停止执行，并开始执行所有在当前 goroutine 中被 `defer` 的函数。
- 然后程序会打印错误信息，并调用 `panic`，导致程序崩溃。
- `log.Panic` 通常用于在遇到无法恢复的错误时停止程序执行。

示例代码如下

```go
package main

import "log"

func main() {
	//log.Panic("Panic")
	log.Panicln("Panicln")
}
```

执行`go run `指令在终端打印内容如下

```bash
2024/09/09 11:08:15 Panicln
panic: Panicln


goroutine 1 [running]:
log.Panicln({0x14000072f28?, 0x0?, 0x14000072f38?})
        /opt/homebrew/opt/go/libexec/src/log/log.go:446 +0x60
main.main()
        /Users/wwhds/Programming_Learning/Project/Go_Learning/log/log_Panic.go:7 +0x44
exit status 2
```


# 2. log.Fatal：

- `log.Fatal` 函数会记录一条错误信息，然后调用 `os.Exit(1)`。
- 当 `log.Fatal` 被调用时，程序会立即停止执行。
- 然后程序会打印错误信息，并调用 `os.Exit(1)`，导致程序以非零状态码退出。
- `log.Fatal` 通常用于在遇到无法恢复的错误时停止程序执行，但不会导致程序崩溃。

示例代码如下

```go
package main

import "log"

func main() {
	log.Fatal("Fatal")
}
```

执行`go run `指令在终端打印内容如下

```bash
2024/09/09 11:11:20 Fatal
exit status 1
```

# 差异示范

如果我们对Panic进行处理的话，代码仍然能执行下去

示例代码修改为如下内容

```go
package main

import "log"

func main() {
	defer func() {
		if handler := recover(); handler != nil { // recover()捕获panic异常
			log.Println("Panic:", handler)
		}
		log.Println("This will not be printed")
	}()
	log.Panicln("Panicln")
}
```

再次执行`go run`指令，终端打印结果如下

```bash
2024/09/09 11:13:16 Panicln
2024/09/09 11:13:16 Panic: Panicln

2024/09/09 11:13:16 This will not be printed
```

可以看到panic处理后代码仍然正常执行了

然而我们对log.Fatal进行处理则没有任何作用，因为log.Fatal直接退出了程序

```go
package main

import "log"

func main() {
	defer func() {
		if handler := recover(); handler != nil { // recover()捕获panic异常
			log.Println("Panic:", handler)
		}
		log.Println("This will not be printed")
	}()
	log.Fatal("Fatal")
}
```

再次执行`go run`，终端打印结果如下

```bash
2024/09/09 11:16:43 Fatal
exit status 1
```

