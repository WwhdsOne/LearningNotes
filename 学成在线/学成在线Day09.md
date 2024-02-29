# 学成在线Day09



# 页面静态化

## 页面静态化概念

根据课程发布的操作流程，执行课程发布后要将课程详情信息页面静态化，生成html页面上传至文件系统。

什么是页面静态化？

课程预览功能通过模板引擎技术在页面模板中填充数据，生成html页面，这个过程是当客户端请求服务器时服务器才开始渲染生成html页面，最后响应给浏览器，服务端渲染的并发能力是有限的。

页面静态化则强调将生成html页面的过程提前，提前使用模板引擎技术生成html页面，当客户端请求时直接请求html页面，由于是静态页面可以使用nginx、apache等高性能的web服务器，并发性能高。

什么时候能用页面静态化技术？

当数据变化不频繁，一旦生成静态页面很长一段时间内很少变化，此时可以使用页面静态化。因为如果数据变化频繁，一旦改变就需要重新生成静态页面，导致维护静态页面的工作量很大。

根据课程发布的业务需求，虽然课程发布后仍可以修改课程信息，但需要经过课程审核，且修改频度不大，所以适合使用页面静态化。

## 页面静态化测试

maven依赖:

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-freemarker</artifactId>
</dependency>
```

测试类代码:

```
@Test
    public void testGenerateHtmlByTemplate() throws IOException, TemplateException {
        //配置freemarker
        Configuration configuration = new Configuration(Configuration.VERSION_2_3_30);

        //加载模板
        //选指定模板路径,classpath下templates下
        //得到classpath路径
        String classpath = this.getClass().getResource("/").getPath();
        configuration.setDirectoryForTemplateLoading(new File(classpath + "/templates/"));
        //设置字符编码
        configuration.setDefaultEncoding("utf-8");

        //指定模板文件名称
        Template template = configuration.getTemplate("course_template.ftl");

        //准备数据
        CoursePreviewDTO coursePreviewInfo = coursePublishService.getCoursePreviewInfo(26L);

        Map<String, Object> map = new HashMap<>();
        map.put("model", coursePreviewInfo);

        //静态化
        //参数1：模板，参数2：数据模型
        String content = FreeMarkerTemplateUtils.processTemplateIntoString(template, map);
        System.out.println(content);
        //将静态化内容输出到文件中
        InputStream inputStream = IOUtils.toInputStream(content);
        //输出流

        //再用拷贝流输出
        FileOutputStream fileOutputStream = new FileOutputStream("D:\\Programming_Learning\\Project\\freemaker\\" + 25 + ".html");
        IOUtils.copy(inputStream, fileOutputStream);
    }
```

## 上传文件测试

maven依赖:

```
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
<!-- Spring Cloud 微服务远程调用 -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
<dependency>
    <groupId>io.github.openfeign</groupId>
    <artifactId>feign-httpclient</artifactId>
</dependency>
<!--feign支持Multipart格式传参-->
<dependency>
    <groupId>io.github.openfeign.form</groupId>
    <artifactId>feign-form</artifactId>
    <version>3.8.0</version>
</dependency>
<dependency>
    <groupId>io.github.openfeign.form</groupId>
    <artifactId>feign-form-spring</artifactId>
    <version>3.8.0</version>
</dependency>
```

feign-dev.yaml配置添加：

```
feign:
  hystrix:
    enabled: true
  circuitbreaker:
    enabled: true
hystrix:
  command:
    default:
      execution:
        isolation:
          thread:
            timeoutInMilliseconds: 30000  #熔断超时时间
ribbon:
  ConnectTimeout: 60000 #连接超时时间
  ReadTimeout: 60000 #读超时时间
  MaxAutoRetries: 0 #重试次数
  MaxAutoRetriesNextServer: 1 #切换实例的重试次数
```

现在需要将课程的静态文件上传到minio，单独存储到course目录下，文件的objectname为"课程id.html"，原有的上传文件接口需要增加一个参数 objectname。

注意feign的配置不能有错

feign上的请求地址与原api有所差异，有时需要单独更改

原api:

```
@RequestMapping(value = "/upload/coursefile",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
```

feign客户端:

```
@PostMapping(value = "/media/upload/coursefile",consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
```

意外BUG

前端工程启动不了发现是修改feign相关配置时删除了原有的配置，下次应该仔细点

MD其实并没有错，由于测试类和实际类名字相同，我启动了半天`测试类`...

# 此处插入重点NGINX内容

我修改配置后使用：

```
nginx.exe -s reload
```

后发现配置并未修改。

**经过调试**后发现，nginx在根目录使用关闭指令后，**并未按照预期关闭**

应使用

```
tasklist /fi "imagename eq nginx.exe"
```

查询所有nginx进程并使用

```
taskkill /pid PID /f
```

全部关闭，新打开的才是能正常使用的

浪费我俩小时服了

## 熔断降级处理

微服务中难免存在服务之间的远程调用，比如：内容管理服务远程调用媒资服务的上传文件接口，当微服务运行不正常会导致无法正常调用微服务，此时会出现异常，如果这种异常不去处理可能导致雪崩效应。

微服务的雪崩效应表现在服务与服务之间调用，当其中一个服务无法提供服务可能导致其它服务也死掉，比如：服务B调用服务A，由于A服务异常导致B服务响应缓慢，最后B、C等服务都不可用，像这样由一个服务所引起的一连串的多个服务无法提供服务即是微服务的雪崩效应，如下图：

![image-20240229192607540](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240229192607540.png)

如何解决由于微服务异常引起的雪崩效应呢？

可以采用熔断、降级的方法去解决。

熔断降级的相同点都是为了解决微服务系统崩溃的问题，但它们是两个不同的技术手段，两者又存在联系。

熔断：

当下游服务异常而断开与上游服务的交互，它就相当于保险丝，下游服务异常触发了熔断，从而保证上游服务不受影响。

![image-20240229192808246](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240229192808246.png)

降级：

当下游服务异常触发熔断后，上游服务就不再去调用异常的微服务而是执行了降级处理逻辑，这个降级处理逻辑可以是本地一个单独的方法。

![image-20240229192920699](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240229192920699.png)

两者都是为了保护系统，熔断是当下游服务异常时一种保护系统的手段，降级是熔断后上游服务处理熔断的方法。

### Hystrix

项目使用**Hystrix**框架实现熔断、降级处理，在feign-dev.yaml中配置

### 定义降级逻辑

1. fallback

```
@FeignClient(value = "media-api",configuration = MultipartSupportConfig.class,fallback = MediaServiceClientFallback.class)
@RequestMapping("/media")
public interface MediaServiceClient{
...

```

定义时指定回调接口fallback

定义一个fallback类MediaServiceClientFallback，此类实现了MediaServiceClient接口。

第一种方法无法取出熔断所抛出的异常，第二种方法定义MediaServiceClientFallbackFactory 可以解决这个问题。

2. fallbackFactory 

   第二种方法在FeignClient中指定fallbackFactory ，如下：

   ```
   @FeignClient(value = "media-api",configuration = MultipartSupportConfig.class,fallbackFactory = MediaServiceClientFallbackFactory.class)
   ```

​	降级处理逻辑：

​	返回一个null对象，上游服务请求接口得到一个null说明执行了降级处理。

​	测试：

​	停止媒资管理服务或人为制造异常观察是否执行降级逻辑。
