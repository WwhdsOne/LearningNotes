# 学成在线Day08

# 课程预览

## 接口定义

遇到了问题：

```
nginx: [error] OpenEvent("Global\ngx_reload_34084") failed (2: The system cannot find the file specified)
```

出现这个错误就是你的nginx关掉了,没有打开,你再次点击nginx.exe运行, 一闪而过后,在cmd控制台下,再次输入nginx.exe -s reload,结果成功

模板修改好之后，点击

![image-20240226173831645](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240226173831645.png)

可以不用重启项目

其他部分基础查询操作即可

预览网页:

```java
@ApiOperation("预览文件")
    @GetMapping("/preview/{mediaId}")
    public RestResponse<String> getPlayUrlByMediaId(@PathVariable String mediaId) {
        MediaFiles mediaFiles = mediaFileService.getFileById(mediaId);
        if(mediaFiles == null || StringUtils.isEmpty(mediaFiles.getUrl())){
            XueChengPlusException.cast("视频还没有转码处理");
        }
        return RestResponse.success(mediaFiles.getUrl());
    }
```

# 课程审核

## 业务流程

![image-20240227135349170](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227135349170.png)

在课程基本表course_base表设置课程审核状态字段，包括：未提交、已提交(未审核)、审核通过、审核不通过。

## 接口开发

### Dao开发

1、查询课程基本信息、课程营销信息、课程计划信息等课程相关信息，整合为课程预发布信息。

2、向课程预发布表course_publish_pre插入一条记录，如果已经存在则更新，审核状态为：已提交。

3、更新课程基本表course_base课程审核状态为：已提交。

约束：

1、对已提交审核的课程不允许提交审核。

2、本机构只允许提交本机构的课程。

3、没有上传图片不允许提交审核。

4、没有添加课程计划不允许提交审核。

代码如下:

```java
@Override
    @Transactional
    public void commitAudit(Long companyId, Long courseId) {
        //查询课程
        //1.对已提交审核的课程不允许提交审核。
        CourseBaseInfoDTO courseBaseInfo = courseBaseInfoService.getCourseBaseInfo(courseId);
        if(courseBaseInfo == null){
            XueChengPlusException.cast("课程不存在");
        }
        //审核状态
        String auditStatus = courseBaseInfo.getAuditStatus();
        //若课程状态为已提交则不允许提交
        if("202003".equals(auditStatus)){
            XueChengPlusException.cast("课程已提交,不允许重复提交");
        }
        //2.没有上传图片不允许提交审核。
        String pic = courseBaseInfo.getPic();
        if( StringUtils.isEmpty(pic) ){
            XueChengPlusException.cast("请上传课程图片");
        }
        //查询课程计划
        //3.没有添加课程计划不允许提交审核。
        List<TeachplanDTO> teachPlanTree = teachPlanService.findTeachPlanTree(courseId);
        if ( teachPlanTree == null || teachPlanTree.isEmpty() ){
            XueChengPlusException.cast("请编写课程计划");
        }
        CoursePublishPre coursePublishPre = new CoursePublishPre();
        BeanUtils.copyProperties(courseBaseInfo, coursePublishPre);
        //将课程基本信息,营销信息,教学计划信息等插入课程预发布表
        //营销信息
        CourseMarket courseMarket = courseMarketMapper.selectById(courseId);
        String courseMarketJsonString = JSON.toJSONString(courseMarket);
        coursePublishPre.setMarket(courseMarketJsonString);
        //计划信息
        String teachPlanJsonString = JSON.toJSONString(teachPlanTree);
        coursePublishPre.setTeachplan(teachPlanJsonString);
        //设置状态为已提交
        coursePublishPre.setStatus("202003");
        //提交时间
        coursePublishPre.setCreateDate(LocalDateTime.now());
        //保存到课程预发布表
        CoursePublishPre coursePublishPreObj = coursePublishPreMapper.selectById(courseId);
        if(coursePublishPreObj == null){
            //插入
            coursePublishPreMapper.insert(coursePublishPre);
        }else{
            //更新
            coursePublishPreMapper.updateById(coursePublishPre);
        }
        CourseBase courseBase = courseBaseMapper.selectById(courseId);
        //更新课程状态为已提交
        courseBase.setAuditStatus("203003");
        courseBaseMapper.updateById(courseBase);
    }
```

# 课程发布

## 数据模型

为了提高网站的速度需要将课程信息进行缓存，并且要将课程信息加入索引库方便搜索，下图显示了课程发布后课程信息的流转情况：

![image-20240227144812329](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227144812329.png)

1. 向内容管理数据库的课程发布表存储课程发布信息，更新课程基本信息表中发布状态为已发布。

2. 向Redis存储课程缓存信息。

3. 向Elasticsearch存储课程索引信息。

4. 请求分布文件系统存储课程静态化页面(即html页面)，实现快速浏览课程详情页面。

## 分布式事务技术方案

### 分布式事务概念

`本地事务:`

平常我们在程序中通过spring去控制事务是利用数据库本身的事务特性来实现的，因此叫数据库事务，由于应用主要靠关系数据库来控制事务，此数据库只属于该应用，所以基于本应用自己的关系型数据库的事务又被称为本地事务。 

本地事务具有ACID四大特性，数据库事务在实现时会将一次事务涉及的所有操作全部纳入到一个不可分割的执行单元，该执行单元中的所有操作 要么都成功，要么都失败，只要其中任一操作执行失败，都将导致整个事务的回滚。 

`分布式事务:`

现在的需求是课程发布操作后将数据写入数据库、redis、elasticsearch、MinIO四个地方，这四个地方已经不限制在一个数据库内，是由四个分散的服务去提供，与这四个服务去通信需要网络通信，而网络存在不可到达性，这种分布式系统环境下，通过与不同的服务进行网络通信去完成事务称之为**分布式事务。**

在分布式系统中分布式事务的场景很多：

例如用户注册送积分，银行转账，创建订单减库存，这些都是分布式事务。

拿转账举例：

我们知道本地事务依赖数据库本身提供的事务特性来实现，因此以下逻辑可以控制本地事务：

```mysql
begin transaction； 
//1.本地数据库操作：张三减少金额 
//2.本地数据库操作：李四增加金额 
commit transation; 
```

但是在分布式环境下，会变成下边这样:

```mysql
begin transaction； 
//1.本地数据库操作：张三减少金额 
//2.远程调用：让李四增加金额 
commit transation;
```

### CAP理论

控制分布式事务首先需要理解CAP理论，什么是CAP理论？

CAP是 `Consistency`、`Availability`、`Partition tolerance`三个词语的缩写，分别表示一致性、可用性、分区容忍性。



![image-20240227145524460](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227145524460.png)

1. `一致性`是指用户不管访问哪一个结点拿到的数据都是最新的，比如查询小明的信息，不能出现在数据没有改变的情况下两次查询结果不一样。

2. `可用性`是指任何时候查询用户信息都可以查询到结果，但不保证查询到最新的数据。
3. `分区容忍性`也叫`分区容错性`，当系统采用分布式架构时由于网络通信异常导致请求中断、消息丢失，但系统依然对外提供服务。

CAP理论要强调的是在分布式系统中这三点`不可能全部满足`，由于是分布式系统就要满足分区容忍性，因为服务之间难免出现网络异常，不能因为局部网络异常导致整个系统不可用。

### 分布式事务控制方案

学习了CAP理论我们知道进行分布式事务控制要在C和A中作出取舍，保证一致性就不要保证可用性，保证可用性就不要保证一致，首先你确认是要CP还是AP，具体要根据应用场景进行判断。

CP的场景：满足C舍弃A，强调一致性。

跨行转账：一次转账请求要等待双方银行系统都完成整个事务才算完成，只要其中一个失败另一方执行回滚操作。

开户操作：在业务系统开户同时要在运营商开户，任何一方开户失败该用户都不可使用，所以要满足CP。

AP的场景：满足A舍弃C，强调可用性。

订单退款，今日退款成功，明日账户到账，只要用户可以接受在一定时间内到账即可。

注册送积分，注册成功积分在24分到账。

支付短信通信，支付成功发短信，短信发送可以有延迟，甚至没有发送成功。

在实际应用中符合AP的场景较多，其实虽然AP舍弃C一致性，实际上最终数据还是达到了一致，也就满足了最终一致性，所以业界定义了BASE理论。

什么是`BASE理论`？

BASE 是 `Basically Available(基本可用)`、`Soft state(软状态)`和 `Eventually consistent (最终一致性)`三个短语的缩写。

基本可用：当系统无法满足全部可用时保证核心服务可用即可，比如一个外卖系统，每到中午12点左右系统并发量很高，此时要保证下单流程涉及的服务可用，其它服务暂时不可用。

软状态：是指可以存在中间状态，比如：打印自己的社保统计情况，该操作不会立即出现结果，而是提示你打印中，请在XXX时间后查收。虽然出现了中间状态，但最终状态是正确的。

最终一致性：退款操作后没有及时到账，经过一定的时间后账户到账，舍弃强一致性，满足最终一致性。

分布式事务控制有哪些`常用的技术方案`？

实现CP就是要实现强一致性:

使用`Seata`框架基于AT模式实现

使用`Seata`框架基于TCC模式实现。

实现AP则要保证最终数据一致性:

使用消息队列通知的方式去实现，通知失败自动重试，达到最大失败次数需要人工处理；

使用任务调度的方案，启动任务调度将课程信息由数据库同步到elasticsearch、MinIO、redis中。

### 课程发布的事务控制方案

目前我们已经有了任务调度的技术积累，这里选用任务调度的方案去实现分布式事务控制，课程发布满足`AP(可用性,分区容忍性)`即可。

时序图如下:

![image-20240227150255989](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227150255989.png)

1. 执行发布操作，内容管理服务存储课程发布表的同时向消息表添加一条“课程发布任务”。这里使用本地事务保证课程发布信息保存成功，同时消息表也保存成功。

2. 任务调度服务定时调度内容管理服务扫描消息表，由于课程发布操作后向消息表插入一条课程发布任务，此时扫描到一条任务。

3. 拿到任务开始执行任务，分别向redis、elasticsearch及文件系统存储数据。

4. 任务完成后删除消息表记录。

# 课程发布接口

service代码如下,有待完善:

```java
@Override
    public void publish(Long companyId, Long courseId) {
        //查询课程预发布信息
        CoursePublishPre coursePublishPre = coursePublishPreMapper.selectById(courseId);
        if(coursePublishPre == null){
            XueChengPlusException.cast("课程预发布信息不存在");
        }
        //课程预发布信息状态
        String status = coursePublishPre.getStatus();
        //检查是否通过审核
        if(!"202004".equals(status)){
            XueChengPlusException.cast("课程未通过审核,不能发布");
        }
        //向课程发布表写入数据
        CoursePublish coursePublish = new CoursePublish();
        BeanUtils.copyProperties(coursePublishPre, coursePublish);

        //发布课程
        CourseBase courseBase = new CourseBase();
        BeanUtils.copyProperties(coursePublishPre, courseBase);
        //先查询课程发布表
        CoursePublish coursePublishObj = coursePublishMapper.selectById(courseId);
        if(coursePublishObj == null) {
            //插入
            coursePublishMapper.insert(coursePublish);
        }else{
            //更新
            coursePublishMapper.updateById(coursePublish);
        }

        //向消息表写记录
        //todo

        //将预发布表信息删除
        coursePublishPreMapper.deleteById(courseId);
    }
```

# 消息处理SDK

## 消息模块技术方案

![image-20240227162519786](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227162519786.png)

上图中红色框内的都是与消息处理相关的操作：

1. 新增消息表

2. 扫描消息表。

3. 更新消息表。

4. 删除消息表。

使用消息表这种方式实现最终事务一致性的地方除了课程发布还有其它业务场景。

![image-20240227162727715](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227162727715.png)

如果在每个地方都实现一套针对消息表定时扫描、处理的逻辑基本上都是重复的，软件的可复用性太低，成本太高。

如何解决这个问题？

针对这个问题可以想到将消息处理相关的逻辑做成一个通用的东西。

是做成`通用的服务`，还是做成`通用的代码组件`呢？

通用的服务是完成一个通用的独立功能，并提供独立的网络接口，比如：项目中的文件系统服务，提供文件的分布式存储服务。

代码组件也是完成一个通用的独立功能，通常会提供API的方式供外部系统使用，比如：fastjson、Apache commons工具包等。

如果将消息处理做成一个通用的服务，该服务需要连接多个数据库，因为它要扫描微服务数据库下的消息表，并且要提供与微服务通信的网络接口，单就针对当前需求而言开发成本有点高。

如果将消息处理做一个SDK工具包相比通用服务不仅可以解决`将消息处理通用化`的需求，还可以`降低成本`。

所以，本项目确定将对消息表相关的处理做成一个SDK组件供各微服务使用,如下图所示：

![image-20240227162824003](C:\Users\Wwhds\AppData\Roaming\Typora\typora-user-images\image-20240227162824003.png)

下边对消息SDK的设计内容进行说明：

1. sdk需要提供执行任务的逻辑吗？

拿课程发布任务举例，执行课程发布任务是要向redis、索引库等同步数据，其它任务的执行逻辑是不同的，所以执行任务在sdk中不用实现任务逻辑，只需要提供一个抽象方法由具体的执行任务方去实现。

2. 如何保证任务的幂等性？

在视频处理章节介绍的视频处理的`幂等性`方案，这里可以采用类似方案，任务执行完成后会从消息表删除，如果消息的状态是完成或不存在消息表中则不用执行。

3. 如何保证任务不重复执行？

采用和视频处理章节一致方案，除了保证任务的幂等性外，任务调度采用`分片广播`，根据分片参数去获取任务，另外阻塞调度策略为`丢弃任务`。

注意：这里是信息同步类任务，即使任务重复执行也没有关系，不再使用抢占任务的方式保证任务不重复执行。

4. 还有一个问题，根据消息表记录是否存在或消息表中的任务状态去保证任务的幂等性，如果一个任务有好几个小任务，比如：课程发布任务需要执行三个同步操作：存储课程到redis、存储课程到索引库，存储课程页面到文件系统。如果其中一个小任务已经完成也不应该去重复执行。这里该如何设计？

将小任务作为任务的不同的阶段，在消息表中设计阶段状态。

调整配置文件后发现无法启动content的api，原因是在nacos中有如下代码片段:

```yaml
# 配置本地优先
spring:
  cloud:
    config:
      override-none: true
```

将其删除即可解决问题

后续内容有待Day09完善