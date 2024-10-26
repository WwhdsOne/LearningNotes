# 1. 设置zap参数

```yaml
zap:
  level: 'debug'
  prefix: '[fiber-demo]'
  format: 'console'
  director: 'logs'
  encode-level: 'CapitalColorLevelEncoder'
  stacktrace-key: 'stacktrace'
  show-line: true
  log-in-console: true
  retention-day: 7
```

- `Level` - 级别
- `Prefix` - 日志前缀
- `Format` - 输出
- `Director` - 日志文件夹
- `EncodeLevel` - 编码级
- `StacktraceKey` - 栈名
- `ShowLine` - 显示行
- `LogInConsole` - 输出控制台
- `RetentionDay` - 日志保留天数

# 2. 转换level

```go
// Levels 根据字符串转化为 zapcore.Levels
func (z *Zap) Levels() []zapcore.Level {
  levels := make([]zapcore.Level, 0, 7)
  level, err := zapcore.ParseLevel(z.Level)
  if err != nil {
    level = zapcore.DebugLevel
  }
  for ; level <= zapcore.FatalLevel; level++ {
    levels = append(levels, level)
  }
  return levels
}
```

这段代码的意思是将debug以及以上的日志类型全部打印

```go
const (
	DebugLevel Level = iota - 1
	InfoLevel
	WarnLevel
	ErrorLevel
	DPanicLevel
	PanicLevel
	FatalLevel
	InvalidLevel = _maxLevel + 1
  ...
)
```

查看源码可知Debug等级是最低等级日志，从Debug循环添加至Fatal意思是将这些等级全部添加到日志打印中。

# 3. 日志等级编码器

通过选择日志编码器，我们可以让不同等级的日志在控制台打印时显示不同的颜色

```go
// LevelEncoder 根据 EncodeLevel 返回 zapcore.LevelEncoder
func (z *Zap) LevelEncoder() zapcore.LevelEncoder {
	switch {
	case z.EncodeLevel == "LowercaseLevelEncoder": // 小写编码器(默认)
		return zapcore.LowercaseLevelEncoder
	case z.EncodeLevel == "LowercaseColorLevelEncoder": // 小写编码器带颜色
		return zapcore.LowercaseColorLevelEncoder
	case z.EncodeLevel == "CapitalLevelEncoder": // 大写编码器
		return zapcore.CapitalLevelEncoder
	case z.EncodeLevel == "CapitalColorLevelEncoder": // 大写编码器带颜色
		return zapcore.CapitalColorLevelEncoder
	default:
		return zapcore.LowercaseLevelEncoder
	}
}
```

我选择使用的是大写编码带颜色

# 4. 日志编码器

```go
func (z *Zap) Encoder() zapcore.Encoder {
	// 创建一个 zapcore.EncoderConfig 配置对象
	config := zapcore.EncoderConfig{
		TimeKey:       "time", // 时间字段的键名
		NameKey:       "name", // 日志记录器名称的键名
		LevelKey:      "level", // 日志级别的键名
		CallerKey:     "caller", // 调用者的键名
		MessageKey:    "msg", // 日志消息的键名
		StacktraceKey: z.StacktraceKey, // 堆栈跟踪的键名，从配置中获取
		LineEnding:    zapcore.DefaultLineEnding, // 行尾字符，使用默认值
		EncodeTime: func(t time.Time, encoder zapcore.PrimitiveArrayEncoder) {
			// 自定义时间格式化函数，将时间格式化为 "prefix 2006-01-02 15:04:05.000" 格式
			encoder.AppendString(z.Prefix + " " + t.Format("2006-01-02 15:04:05.000"))
		},
		EncodeLevel:    z.LevelEncoder(), // 自定义日志级别编码器，从配置中获取
		EncodeCaller:   zapcore.FullCallerEncoder, // 调用者编码器，使用完整路径
		EncodeDuration: zapcore.SecondsDurationEncoder, // 持续时间编码器，使用秒数
	}

	// 根据配置中的格式选择编码器
	if z.Format == "json" {
		// 如果格式为 "json"，则返回 JSON 编码器
		return zapcore.NewJSONEncoder(config)
	}
	// 否则返回控制台编码器
	return zapcore.NewConsoleEncoder(config)
}
```

# 5. 日志初始化

由于zaplog不带有日志切割功能，我们需要外部库来实现日志切割

```bash
go get -u 	"github.com/natefinch/lumberjack"
```

然后我们编写zap初始化函数

```go
func InitZap() *zap.Logger {

	// 获取配置文件
	z := global.CONFIG.Zap
	// 创建一个 Zap 配置实例
	zapConfig := &config.Zap{
		Level:         z.Level,
		Prefix:        z.Prefix,
		Format:        z.Format,
		Director:      z.Director,
		EncodeLevel:   z.EncodeLevel,
		StacktraceKey: z.StacktraceKey,
		ShowLine:      z.ShowLine,
		LogInConsole:  z.LogInConsole,
		RetentionDay:  z.RetentionDay,
	}

	// 获取 zapcore.Level 数组
	levels := zapConfig.Levels()

	// 创建 zapcore.Encoder
	encoder := zapConfig.Encoder()

	// 创建 lumberjack 日志轮转器
	lumberjackLogger := &lumberjack.Logger{
		//todo 日后替换为配置文件中的地址
		Filename:   "/Users/wwhds/Programming_Learning/Project/fiber-demo/logs/app.log",
		MaxSize:    10, // 单位：MB
		MaxBackups: 3,
		MaxAge:     zapConfig.RetentionDay, // 单位：天
		Compress:   true,
	}

	// 创建多个输出目标
	consoleSyncer := zapcore.AddSync(os.Stdout)
	fileSyncer := zapcore.AddSync(lumberjackLogger)

	// 创建多个 zapcore.Core
	consoleCore := zapcore.NewCore(encoder, consoleSyncer, levels[0])
	fileCore := zapcore.NewCore(encoder, fileSyncer, levels[0])

	// 合并多个 zapcore.Core
	core := zapcore.NewTee(consoleCore, fileCore)

	// 创建 zap.Logger
	logger := zap.New(core, zap.AddCaller(), zap.AddStacktrace(zapcore.ErrorLevel))

	return logger
}
```

# 6. 在Fiber中使用自定义的zaplog中间件

查看源码可知fiber的handler接口定义如下

```go
type Handler = func(Ctx) error
```

那么我们可以自定义一个handler使用

```go
func ZapFiberLogger() fiber.Handler {
	return func(c fiber.Ctx) error {
		start := time.Now()
		path := c.Path()
		query := c.Queries()
		// 获取 Bearer Token
		//bearerToken := c.Request.Header.Get("Authorization")
		err := c.Next()

		cost := time.Since(start)

		global.LOG.Info(path,
			zap.Int("status", c.Response().StatusCode()),
			zap.String("method", c.Method()),
			zap.String("path", path),
			zap.String("query", utils.MapToString(query)), //map转string是自定义的方法
			zap.String("ip", c.IP()),
			zap.String("user-agent", string(c.Request().Header.UserAgent())),
			//zap.String("bearer_token", bearerToken),
			zap.Duration("cost", cost),
		)
		return err
	}
}
```

这样我们就可以对每次请求都打印日志了

# 7. 自定义错误处理器

Fiber框架中的错误处理器需要在`fiber.Config`中指定。

查看源码可知错误处理器接口定义如下

```go
type ErrorHandler = func(Ctx, error) error
```

那么我们可以定义一个处理器

```go
func ZapFiberErrorHandler() fiber.ErrorHandler {
	return func(c fiber.Ctx, err error) error {
		// 记录请求开始时间
		start := time.Now()

		//code := fiber.StatusInternalServerError
		defer func() {
			r := recover()
			if r != nil {
				// 获取堆栈信息

				stack := debug.Stack()

				// 将 panic 信息和堆栈写入日志
				global.LOG.Error("Panic Recovered",
					zap.String("stack", string(stack)),
					zap.String("method", c.Method()),
					zap.String("path", c.Path()),
					zap.String("query", c.OriginalURL()),
					zap.String("ip", c.IP()),
					zap.Duration("latency", time.Since(start)),
				)

				response.FailWithMessage(err.Error(), c)

				return
			}
		}()

		if err = c.Next(); err != nil {
			// 使用 zap 记录 Fiber 的错误
			global.LOG.Error("Handler Error",
				zap.Error(err),
				zap.String("method", c.Method()),
				zap.String("path", c.Path()),
				zap.String("query", c.OriginalURL()),
				zap.String("ip", c.IP()),
				zap.Duration("latency", time.Since(start)),
			)

			// 返回错误响应
			response.FailWithMessage(err.Error(), c)
		}
		return nil
	}
}
```

使用 `defer` 语句的目的是确保在函数返回之前捕获和处理 panic，并记录相关的日志信息。这有助于在发生 panic 时进行调试和故障排查。通过 `defer` 语句，你可以确保无论函数在何处返回，panic 都会被捕获并处理。

# 8. 效果展示

我们在一个Get方法中手动触发`panic`

```go
func GetStudent(c fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	panic("LOLOLO")
	if err != nil {
		return err
	}
	student, err := service.GetStudent(id)
	if err != nil {
		response.FailWithMessage(err.Error(), c)
		return err
	}
	response.OkWithData(student, c)
	return nil
}
```

