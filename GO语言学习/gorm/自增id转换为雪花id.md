# 1. 下载依赖

```bash
go get -u github.com/bwmarrin/snowflake
```

# 2. 自制雪花ID工具类

```go
func GenerateSnowflakeId() (int64, error) {
	node, err := snowflake.NewNode(1)
	if err != nil {
		return 0, err
	}
	return node.Generate().Int64(), nil
}
```

使用上述代码构建一个工具类

# 3. 为结构体实现接口

```go
type Student struct {
	gorm.Model
	Name      string       `json:"name"`
	Age       int          `json:"age"`
	Sex       int          `json:"sex"`
	Courses   []Course     `gorm:"many2many:student_course;"`
}

func (s *Student) BeforeCreate(db *gorm.DB) error {
	id, err := utils.GenerateSnowflakeId()
	if err != nil {
		return err
	}
	s.ID = id
	return nil
}
```

我们执行插入操作后可以在数据库中看到

![image-20241019082918184](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20241019082918184.png)

可以看到插入时id为生成的雪花id

# 4. 优化为通用结构体

如果我们有更多的结构体也需要这几个字段，那么我们需要多次重复定义这几个属性，我们可以通过复用属性来简化代码

我们可以定义一个通用Model，通过组合放在对应的结构体中。

首先我们借鉴一下`gorm.Model`

```go
type Model struct {
	ID        uint `gorm:"primarykey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt DeletedAt `gorm:"index"`
}
```

- 由于雪花id使用的是int64，所以ID需要修改为int64

- 时间相关gorm在自动迁移时使用的datetime，这里推荐使用timestamp

  - 推荐使用 `TIMESTAMP` 而非 `DATETIME` 的原因如下：

    1. **时区支持**：`TIMESTAMP` 自动根据时区调整时间，适合跨时区应用，而 `DATETIME` 不处理时区。
    2. **存储效率**：`TIMESTAMP` 占用 4 字节，比 `DATETIME`（8 字节）更节省存储空间。
    3. **自动更新**：`TIMESTAMP` 支持自动更新当前时间，适合记录创建和更新时间。
    4. **时间范围**：`TIMESTAMP` 适用于 1970-2038 年的时间范围，`DATETIME` 范围更广（1000-9999 年）。
    5. **可移植性**：`TIMESTAMP` 在多个数据库中标准化程度更高。
  
    总结：如果不涉及超长时间范围或特殊历史时间，`TIMESTAMP` 更高效且便捷。
  

那么我们自己封装的Model如下

```go
// BaseModel 是一个通用的模型，包含 ID、CreatedAt、UpdatedAt 和 DeletedAt 字段

type BaseModel struct {
	ID        int64          `gorm:"primarykey;column:id"`
	CreatedAt time.Time      `gorm:"type:timestamp;autoCreateTime"`
	UpdatedAt time.Time      `gorm:"type:timestamp;autoUpdateTime"`
	DeletedAt gorm.DeletedAt `gorm:"type:timestamp;index"`
}
```

我们使用组合将其替换学生类中的`gorm.Model`

删除原有数据库表后再次启动程序，进行新增和删除操作后内容如下

![image-20241019091234843](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20241019091234843.png)

完工！
