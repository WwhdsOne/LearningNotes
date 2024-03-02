# 学成在线Day01

### 1 开发工具版本

![image-20240207192456061](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240207192456061.png)

### 2 环境搭建

|             **出现问题**              |                        **解决方案**                        |
| :-----------------------------------: | :--------------------------------------------------------: |
|        虚拟机启动后IP地址不对         |        通过主机cmd的ipconfig指令查看正确虚拟机指令         |
|          无法连接Mysql等服务          |             应按照教程填写IP地址，不要自己发挥             |
| 引入资料的maven依赖爆红显示找不到文件 | 将<dependencyManagement>标签注释后加载完成后再取消注释即可 |



我们创建了项目父工程、项目基础工程，如下图：

![img](file:///C:/Users/Wwhds/AppData/Local/Temp/msohtmlclip1/01/clip_image002.gif)

接下来要创建内容管理模块的工程结构。

本项目是一个前后端分离项目，前端与后端开发人员之间主要依据接口进行开发。

下图是前后端交互的流程图：

1、前端请求后端服务提供的接口。（通常为http协议 ）

2、后端服务的控制层Controller接收前端的请求。

3、Contorller层调用Service层进行业务处理。

4、Service层调用Dao持久层对数据持久化。

![img](file:///C:/Users/Wwhds/AppData/Local/Temp/msohtmlclip1/01/clip_image004.gif)

 

整个流程分为前端、接口层、业务层三部分。

所以模块工程的结构如下图所示：

![img](file:///C:/Users/Wwhds/AppData/Local/Temp/msohtmlclip1/01/clip_image006.gif)

xuecheng-plus-content-api：接口工程，为前端提供接口。

xuecheng-plus-content-service: 业务工程，为接口工程提供业务支撑。

xuecheng-plus-content-model: 数据模型工程，存储数据模型类、数据传输类型等。

结合项目父工程、项目基础工程后，如下图：

![img](file:///C:/Users/Wwhds/AppData/Local/Temp/msohtmlclip1/01/clip_image008.gif)

xuecheng-plus-content：内容管理模块工程，负责聚合xuecheng-plus-content-api、xuecheng-plus-content-service、xuecheng-plus-content-model。

#### 子文件pom文件爆红

复制材料中的maven以来后xuecheng-plus-content-api、xuecheng-plus-content-service、xuecheng-plus-content-model的pom文件爆红报错信息为:

> # Invalid packaging for parent POM must be “pom“ but is “jar“

百度后发现是因为父级的pom.xml中对

```xml
<packaging>xxx</packaging>
```

节点定义不正确,或者没有定义，应该定义成

```xml
<packaging>pom</packaging>
```

#### 源根之外的java文件

若java文件前方图标是茶杯，且鼠标移上去显示***源根之外的java文件***那么将父目录标记为源代码根目录即可

![image-20240208191631060](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240208191631060.png)

### 课程查询功能开发

1.页面信息传入类和返回结果类生成

![image-20240208202644550](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240208202644550.png)

PageResult使用了泛型使得不同类型的查询结果均可以使用,提高了代码复用率

2.Json日期信息转换类注入

![image-20240208202956692](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240208202956692.png)

3.Swagger依赖生成接口文档

![image-20240208203219030](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240208203219030.png)
