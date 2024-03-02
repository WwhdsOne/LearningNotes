# 学成在线Day05

# 媒资管理开发流程

见word资料

# 微服务搭建

在xuecheng-plus-parent中添加依赖管理 

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>${spring-cloud-alibaba.version}</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

在内容管理模块的接口工程，因为api是启动Http服务，在其中添加如下依赖

```xml
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
</dependency>
```

在bootstrap.yml文件加入如下配置:

```yaml
#微服务配置
spring:
  application:
    name: content-api #微服务名称
  cloud:
    nacos:
      server-addr: 192.168.101.65:8848
      discovery: #服务相关配置
        namespace: dev-Wwh
        group: xuecheng-plus-project
      config:
        namespace: dev-Wwh
        group: xuecheng-plus-project
        file-extension: yaml
        refresh-enabled: true
  profiles:
    active: dev
```

在搭建Nacos服务发现中心之前需要搞清楚两个概念：namespace和group

- namespace:用于区分环境、比如：开发环境、测试环境、生产环境。

- group:用于区分项目，比如：xuecheng-plus项目、xuecheng2.0项目

### **配置三要素**

搭建完成Nacos服务发现中心，下边搭建Nacos为配置中心，其目的就是通过Nacos去管理项目的所有配置。

先将项目中的配置文件分分类：

1、每个项目特有的配置

是指该配置只在有些项目中需要配置，或者该配置在每个项目中配置的值不同。

比如：spring.application.name每个项目都需要配置但值不一样，以及有些项目需要连接数据库而有些项目不需要，有些项目需要配置消息队列而有些项目不需要。

2、项目所公用的配置

是指在若干项目中配置内容相同的配置。比如：redis的配置，很多项目用的同一套redis服务所以配置也一样。

另外还需要知道nacos如何去定位一个具体的配置文件，即：namespace、group、dataid. 

1、通过namespace、group找到具体的环境和具体的项目。

2、通过dataid找到具体的配置文件，dataid有三部分组成

***比如：content-service-dev.yaml配置文件 由（content-service）-（dev）. (yaml)三部分组成***

***content-service：第一部分，它是在application.yaml中配置的应用名，即spring.application.name的值。***

***dev：第二部分，它是环境名，通过spring.profiles.active指定，***

***Yaml: 第三部分，它是配置文件 的后缀，目前nacos支持properties、yaml等格式类型，本项目选择yaml格式类型。***

### 配置content-service

在content-service工程的test/resources 中添加bootstrap.yaml，内容如下：

```yaml
spring:
  application:
    name: content-service
  cloud:
    nacos:
      server-addr: 192.168.101.65:8848
      discovery:
        namespace: dev
        group: xuecheng-plus-project
      config:
        namespace: dev
        group: xuecheng-plus-project
        file-extension: yaml
        refresh-enabled: true
#profiles默认为dev
  profiles:
    active: dev
```

通过运行观察控制台打印出下边的信息，NacosRestTemplate.java通过Post方式与nacos服务端交互读取配置信息。

```java
[NacosRestTemplate.java:476] - HTTP method: POST, url: http://192.168.101.65:8848/nacos/v1/cs/configs/listener, body: {Listening-Configs=content-service.yaml?xuecheng-plus-project??dev?content-service-dev.yaml?xuecheng-plus-project?88459b1483b8381eccc2ef462bd59182?dev?content-service?xuecheng-plus-project??dev?, tenant=dev}
```

### 配置content-api

内容如下：

```yaml
#微服务配置
spring:
  application:
    name: content-api
  cloud:
    nacos:
      server-addr: 192.168.101.65:8848
      discovery:
        namespace: dev
        group: xuecheng-plus-project
      config:
        namespace: dev
        group: xuecheng-plus-project
        file-extension: yaml
        refresh-enabled: true
        extension-configs:
          - data-id: content-service-${spring.profiles.active}.yaml
            group: xuecheng-plus-project
            refresh: true
  profiles:
    active: dev
```

通过这一部分，能让其引用service层的数据库连接配置：

```yaml
extension-configs:
  - data-id: content-service-${spring.profiles.active}.yaml
    group: xuecheng-plus-project
    refresh: true
```

将swagger配置和logging配置抽取到项目公共组，来让所有项目通用配置这部分内容

```yaml
shared-configs:
  - data-id: swagger-${spring.profiles.active}.yaml       #swagger文件配置
    group: xuecheng-plus-common
    refresh: true
  - data-id: logging-${spring.profiles.active}.yaml       #日志文件配置
    group: xuecheng-plus-common
    refresh: true
```

nacos中并未对`extension-configs`和`shared-configs`的差别

但是我们在使用时，若使用公共配置文件，则需要配置`shared-configs`

若使用私有配置，则需要配置`extension-configs`

### 配置优先级

到目前为止已将所有微服务的配置统一在nacos进行配置，用到的配置文件有本地的配置文件 bootstrap.yaml和nacos上的配置文件，SpringBoot读取配置文件 的顺序如下：

![image-20240216202431287](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240216202431287.png)

引入配置文件的形式有：

1、以项目应用名方式引入

2、以扩展配置文件方式引入

3、以共享配置文件 方式引入

4、本地配置文件

各配置文件 的优先级：项目应用名配置文件 > 扩展配置文件 > 共享配置文件 > 本地配置文件。

想让本地最优先，可以在nacos配置文件 中配置如下即可实现：

```yaml
spring:
 cloud:
  config:
    override-none: true
```

# 分布式文件系统

简介请查看word中分布式文件系统这一章:[分布式简介](E:\学习资料\学成在线项目—资料\day05 媒资管理 Nacos Gateway MinIO\资料\第3章媒资管理模块v3.1.docx)

我们使用Minio分布式文件存储系统

### SDK

操作教程地址：https://docs.min.io/docs/java-client-quickstart-guide.html

最低需求Java 1.8或更高版本

Maven依赖:

```xml
<dependency>
    <groupId>io.minio</groupId>
    <artifactId>minio</artifactId>
    <version>8.4.3</version>
</dependency>
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp</artifactId>
    <version>4.8.1</version>
</dependency>
```



# 上传图片

首先分析接口：

请求地址：/media/upload/coursefile

请求内容：**Content-Type:** multipart/form-data;

form-data; name="filedata"; filename="具体的文件名称"

```java
@ApiOperation("上传图片")
@PostMapping(value = "/upload/coursefile",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
public UploadFileResultDTO upload(@RequestPart("file") MultipartFile file) {
    //调用service上传文件
    return null;
}
```

`consumes` 请求提交内容类型，`MediaType`方式，如 `application/json`、`application/x-www-urlencode`、`multipart/form-data`等

`@RequestPart`用于将`multipart/form-data`类型数据映射到控制器处理方法的参数中。除了`@RequestPart`注解外，`@RequestParam`同样可以用于此类操作。

上传到Minio需要进行的操作

```java
//1.文件上传到Minio
String fileName = uploadFileParamsDto.getFilename();
//获取文件拓展名
String extension = StringUtils.substringAfterLast(fileName, ".");

//根据拓展名获取媒体类型
String mimeType = getMimeType(extension);

String defaultFolderPath = getDefaultFolderPath();

//获取MD5值
String fileMd5 = getFileMd5(new File(localFilePath));

//objectName以年月日作为名称存储
String objectName = defaultFolderPath + fileMd5 + extension;

boolean result = addMediaFilesToMinIO(localFilePath, mimeType, bucket_mediaFiles, objectName);
if(!result){
    XueChengPlusException.cast("文件上传失败");
}
```

在Controller层，接收到文件后要创建暂时文件

```java
//创建临时文件
File tempFile = File.createTempFile("minio", "temp");
file.transferTo(tempFile);
```

`File.createTempFile` 是 Java 中的一个方法，用于创建一个临时文件。这个方法是 `java.io.File` 类的一部分。

`transferTo` 是 Java 中的一个方法，用于将文件的内容转移到另一个文件中。这个方法是 `java.nio.file.Files` 类的一部分，它使用了 Java 的 NIO（Non-blocking I/O）特性，可以更高效地处理文件操作。

这个方法会在默认的临时文件目录中创建一个新的空文件，文件名是由给定的前缀和后缀生成的。这个临时文件的路径可以通过 `tempFile.getPath()` 获取。

注意：创建的临时文件在 JVM 退出时不会自动删除，需要手动删除。如果你希望临时文件在 JVM 退出时自动删除，可以调用 `tempFile.deleteOnExit()` 方法。

# Service事务优化

上边的service方法优化后并测试通过，现在思考关于uploadFile方法的是否应该开启事务。

目前是在uploadFile方法上添加@Transactional，当调用uploadFile方法前会开启数据库事务，如果上传文件过程时间较长那么数据库的事务持续时间就会变长，这样数据库链接释放就慢，最终导致数据库链接不够用。

我们只将addMediaFilesToDb方法添加事务控制即可,uploadFile方法上的@Transactional注解去掉。

我们人为在int insert = mediaFilesMapper.insert(mediaFiles);下边添加一个异常代码int a=1/0;

测试是否事务控制。很遗憾，事务控制失败。

方法上已经添加了@Transactional注解为什么该方法不能被事务控制呢？

如果是在uploadFile方法上添加@Transactional注解就可以控制事务，去掉则不行。

**现在的问题其实是一个非事务方法调同类一个事务方法，事务无法控制，这是为什么？**

下边分析原因：

如果在uploadFile方法上添加@Transactional注解，代理对象执行此方法前会开启事务，如下图：

![image-20240217202502483](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240217202502483.png)

如果在uploadFile方法上没有@Transactional注解，代理对象执行此方法前不进行事务控制，如下图：

![image-20240217202523999](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240217202523999.png)

所以判断该方法是否可以事务控制必须保证是通过代理对象调用此方法，且此方法上添加了@Transactional注解。

现在在addMediaFilesToDb方法上添加@Transactional注解，也不会进行事务控制是因为并不是通过代理对象执行的addMediaFilesToDb方法。为了判断在uploadFile方法中去调用addMediaFilesToDb方法是否是通过代理对象去调用，我们可以打断点跟踪。

我们发现在uploadFile方法中去调用addMediaFilesToDb方法不是通过代理对象去调用，**而是直接调用本类的方法**。

简而言之：只有通过调用代理类来执行事务操作才可以控制事务

那么解决方案就明了了，首先我们将这个方法在接口中创建，然后我们将service类代理对象注入其中，并利用代理对象调用数据库函数即可
