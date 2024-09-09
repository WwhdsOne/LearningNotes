Go 语言的 Module 新特性是在 go1.11 的发布之后才支持的，这是 Go 语言新的一套依赖管理系统。

以下是自定义go包后进行在另一个模块进行导入的例子

# 1. 创建CALC包

首先创建一个calc.go文件，在其中写入

```go
package calc

func Sum(a, b int) int {
	return a + b
}
```

然后在当前目录下执行

```bash
go mod init github.com/wwhds/calc
```

