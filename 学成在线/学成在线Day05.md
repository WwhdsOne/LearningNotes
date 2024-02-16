# 学成在线Day05

# 媒资管理开发流程

见word资料

# 微服务搭建

在xuecheng-plus-parent中添加依赖管理 

```
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-alibaba-dependencies</artifactId>
    <version>${spring-cloud-alibaba.version}</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

在内容管理模块的接口工程，因为api是启动Http服务，在其中添加如下依赖

```
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

```
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

```
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

```
[NacosRestTemplate.java:476] - HTTP method: POST, url: http://192.168.101.65:8848/nacos/v1/cs/configs/listener, body: {Listening-Configs=content-service.yaml?xuecheng-plus-project??dev?content-service-dev.yaml?xuecheng-plus-project?88459b1483b8381eccc2ef462bd59182?dev?content-service?xuecheng-plus-project??dev?, tenant=dev}
```

### 配置content-api

内容如下：

```
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

```
extension-configs:
  - data-id: content-service-${spring.profiles.active}.yaml
    group: xuecheng-plus-project
    refresh: true
```

将swagger配置和logging配置抽取到项目公共组，来让所有项目通用配置这部分内容

```
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

```
spring:
 cloud:
  config:
    override-none: true
```

# 分布式文件系统

简介请查看word中分布式文件系统这一章:[分布式简介](E:\学习资料\学成在线项目—资料\day05 媒资管理 Nacos Gateway MinIO\资料\第3章媒资管理模块v3.1.docx)

### SDK

操作教程地址：https://docs.min.io/docs/java-client-quickstart-guide.html

最低需求Java 1.8或更高版本

Maven依赖:

```
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



