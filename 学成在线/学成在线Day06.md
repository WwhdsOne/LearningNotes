# 学成在线Day06



# 上传视频

## 断点续传技术

### 1.什么是断点续传

通常视频文件都比较大，所以对于媒资系统上传文件的需求要满足大文件的上传要求。http协议本身对上传文件大小没有限制，但是客户的网络环境质量、电脑硬件环境等参差不齐，如果一个大文件快上传完了网断了没有上传完成，需要客户重新上传，用户体验非常差，所以对于大文件上传的要求最基本的是断点续传。

什么是断点续传：

​    引用百度百科：断点续传指的是在下载或上传时，将下载或上传任务（一个文件或一个压缩包）人为的划分为几个部分，每一个部分采用一个线程进行上传或下载，如果碰到网络故障，可以从已经上传或下载的部分开始继续上传下载未完成的部分，而没有必要从头开始上传下载，断点续传可以提高节省操作时间，提高用户体验性。

断点续传流程如下图：

![image-20240217205319182](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240217205319182.png)

流程如下：

1、前端上传前先把文件分成块

2、一块一块的上传，上传中断后重新上传，已上传的分块则不用再上传

3、各分块上传完成最后在服务端合并文件

### 2.文件分块测试

文件分块测试代码：

```java
//分块测试
@Test
public void testChunk() throws IOException {
    File sourceFile = new File("C:\\Users\\Administrator\\Desktop\\分块测试\\test.mp4");

    String fileChunkPath = "C:\\Users\\Administrator\\Desktop\\分块测试";
    //分块大小
    int chunkSize = 1024 * 1024 * 1;
    //分块数量
    int chunkNum = (int) Math.ceil(sourceFile.length() * 1.0 / chunkSize);
    RandomAccessFile ref_r = new RandomAccessFile(sourceFile, "r");
    //缓冲区
    byte[] b = new byte[1024];
    for ( int i = 0; i < chunkNum; i++ ) {
        //创建分块文件
        File chunkFile = new File(fileChunkPath + i);
        //分块文件写入流
        RandomAccessFile ref_w = new RandomAccessFile(chunkFile, "rw");
        int len = -1;
        //读取文件
        while ( (len = ref_r.read(b)) != -1 ) {
            ref_w.write(b, 0, len);
            if ( chunkFile.length() >= chunkSize ) {
                break;
            }
        }
    }
}
```

其中用到了`RandomAccessFile`

RandomAccessFile从字面意思翻译：随机通行文件

下面开始介绍一下RandomAccessFile，该类是直接继承Object的类，既可以读取文件内容，也可以向文件输出数据。

RandomAccessFile支持“随机访问”的方式，程序快可以直接跳转到文件的**任意地方**来读写数据。

RandomAccessFile的一个重要使用场景就是网络请求中的多线程下载及断点续传。

文件分块合并测试代码：

```java
@Test
public void testMerge() throws Exception {
    //找到分块文件路径
    File chunkFolder = new File("C:\\Users\\Wwhds\\Desktop\\分块测试\\chunk");
    //源文件
    File sourceFile = new File("C:\\Users\\Wwhds\\Desktop\\分块测试\\test.mp4");
    //合并文件
    File mergeFile = new File("C:\\Users\\Wwhds\\Desktop\\分块测试\\test_merge.mp4");


    //取出所有分块文件
    File[] chunkFiles = chunkFolder.listFiles();

    List<File> list = null;
    if ( chunkFiles != null ) {
        list = Arrays.asList(chunkFiles);
    }
    //根据文件名称排序list
    if ( list != null ) {
        list.sort(Comparator.comparingInt(o -> Integer.parseInt(o.getName())));
    }
    RandomAccessFile raf_rw = new RandomAccessFile(mergeFile, "rw");
    byte b[] = new byte[1024];
    for ( File file : list ) {
        RandomAccessFile raf_r = new RandomAccessFile(file, "r");
        int len;
        while ( (len = raf_r.read(b)) != -1 ) {
            raf_rw.write(b, 0, len);
        }
        raf_r.close();
    }
    raf_rw.close();
    System.out.println("合并完成");				//MD5验证
    if ( DigestUtils.md5Hex(new FileInputStream(sourceFile)).equals(DigestUtils.md5Hex(new FileInputStream(mergeFile))) ) {
        System.out.println("文件一致");
    }else {
        System.out.println("文件不一致");
    }
}
```

### 3.视频上传流程

![image-20240218151425388](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240218151425388.png)

1、前端对文件进行分块。

2、前端上传分块文件前请求媒资服务检查文件是否存在，如果已经存在则不再上传。

3、如果分块文件不存在则前端开始上传

4、前端请求媒资服务上传分块。

5、媒资服务将分块上传至MinIO。

6、前端将分块上传完毕请求媒资服务合并分块。

7、媒资服务判断分块上传完成则请求MinIO合并文件。

8、合并完成校验合并后的文件是否完整，如果完整则上传完成，否则删除文件。

### 4.Minio文件上传测试

注意分块内容必须大于等于5M

```java
List<ComposeSource> sources = Stream.iterate(0, i -> ++i)
    .limit(42)
    .map(i -> ComposeSource.builder()
         .bucket("testbucket")
         .object("chunk/" + i)
         .build())
    .collect(Collectors.toList());
```

stream流全新用法

# 上传分块

上传文件大小限制需要解除

```yaml
spring:
  servlet:
    multipart:
      enabled: true
      max-file-size: 50MB			//上传文件最大限制
      max-request-size: 50MB		//请求文件最大限制
```

在nacos配置即可

内容过于庞大，请在代码文件中查看

# 视频处理

视频上传成功后需要对视频进行转码处理。

什么是视频编码？查阅百度百科如下：

详情参考 ：[https://baike.baidu.com/item/%E8%A7%86%E9%A2%91%E7%BC%96%E7%A0%81/839038](https://baike.baidu.com/item/视频编码/839038)

首先我们要分清文件格式和编码格式：

文件格式：是指.mp4、.avi、.rmvb等 这些不同扩展名的视频文件的文件格式 ，视频文件的内容主要包括视频和音频，其文件格式是按照一 定的编码格式去编码，并且按照该文件所规定的封装格式将视频、音频、字幕等信息封装在一起，播放器会根据它们的封装格式去提取出编码，然后由播放器解码，最终播放音视频。

音视频编码格式：通过音视频的压缩技术，将视频格式转换成另一种视频格式，通过视频编码实现流媒体的传输。比如：一个.avi的视频文件原来的编码是a，通过编码后编码格式变为b，音频原来为c，通过编码后变为d。

 

音视频编码格式各类繁多，主要有几下几类：

MPEG系列

（由ISO[国际标准组织机构]下属的MPEG[运动图象专家组]开发 ）视频编码方面主要是Mpeg1（vcd用的就是它）、Mpeg2（DVD使用）、Mpeg4（的DVDRIP使用的都是它的变种，如：divx，xvid等）、Mpeg4 AVC（正热门）；音频编码方面主要是MPEG Audio Layer 1/2、MPEG Audio Layer 3（大名鼎鼎的mp3）、MPEG-2 AAC 、MPEG-4 AAC等等。注意：DVD音频没有采用Mpeg的。

H.26X系列

（由ITU[国际电传视讯联盟]主导，侧重网络传输，注意：只是视频编码）

包括H.261、H.262、H.263、H.263+、H.263++、H.264（就是MPEG4 AVC-合作的结晶）

目前最常用的编码标准是视频H.264，音频AAC。

# 分布式调度

对一个视频的转码可以理解为一个任务的执行，如果视频的数量比较多，如何去高效处理一批任务呢？

1、多线程

多线程是充分利用单机的资源。

2、分布式加多线程

充分利用多台计算机，每台计算机使用多线程处理。

方案2可扩展性更强。

方案2是一种分布式任务调度的处理方案。

什么是分布式任务调度？

我们可以先思考一下下面业务场景的解决方案：

​    每隔24小时执行数据备份任务。

​    12306网站会根据车次不同，设置几个时间点分批次放票。

​    某财务系统需要在每天上午10点前结算前一天的账单数据，统计汇总。

​    商品成功发货后，需要向客户发送短信提醒。

**什么是分布式任务调度？**

​    通常任务调度的程序是集成在应用中的，比如：优惠卷服务中包括了定时发放优惠卷的的调度程序，结算服务中包括了定期生成报表的任务调度程序，由于采用分布式架构，一个服务往往会部署多个冗余实例来运行我们的业务，在这种分布式系统环境下运行任务调度，我们称之为**分布式任务调度**，如下图：

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318125528197.png" alt="image-20240318125528197" style="zoom:50%;" />



**分布式调度要实现的目标：**

​    不管是任务调度程序集成在应用程序中，还是单独构建的任务调度系统，如果采用分布式调度任务的方式就相当于将任务调度程序分布式构建，这样就可以具有分布式系统的特点，并且提高任务的调度处理能力：

1. 并行任务调度

​    并行任务调度实现靠多线程，如果有大量任务需要调度，此时光靠多线程就会有瓶颈了，因为一台计算机CPU的处理能力是有限的。

​    如果将任务调度程序分布式部署，每个结点还可以部署为集群，这样就可以让多台计算机共同去完成任务调度，我们可以将任务分割为若干个分片，由不同的实例并行执行，来提高任务调度的处理效率。

2. 高可用

​    若某一个实例宕机，不影响其他实例来执行任务。

3. 弹性扩容

​    当集群中增加实例就可以提高并执行任务的处理效率。

4. 任务管理与监测

​    对系统中存在的所有定时任务进行统一的管理及监测。让开发人员及运维人员能够时刻了解任务执行情况，从而做出快速的应急处理响应。

5. 避免任务重复执行

​    当任务调度以集群方式部署，同一个任务调度可能会执行多次，比如在上面提到的电商系统中到点发优惠券的例子，就会发放多次优惠券，对公司造成很多损失，所以我们需要控制相同的任务在多个运行实例上只执行一次。

我们使用xxl来执行任务调度

XXL-JOB是一个轻量级分布式任务调度平台，其核心设计目标是开发迅速、学习简单、轻量级、易扩展。现已开放源代码并接入多家公司线上产品线，开箱即用。

官网：https://www.xuxueli.com/xxl-job/

文档：https://www.xuxueli.com/xxl-job/#%E3%80%8A%E5%88%86%E5%B8%83%E5%BC%8F%E4%BB%BB%E5%8A%A1%E8%B0%83%E5%BA%A6%E5%B9%B3%E5%8F%B0XXL-JOB%E3%80%8B

maven依赖：

```xml
<dependency>
    <groupId>com.xuxueli</groupId>
    <artifactId>xxl-job-core</artifactId>
</dependency>
```

配置文件:

```yaml
xxl:
  job:
    admin: 
      addresses: http://192.168.101.65:8088/xxl-job-admin
    executor:
      appname: media-process-service
      address: 
      ip: 
      port: 9999
      logpath: /data/applogs/xxl-job/jobhandler
      logretentiondays: 30
    accessToken: default_token
```

添加调度

在新增处新增测试任务，注意bean名称要与注册内容相同，可以用cron表达式调度

![image-20240218203347215](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240218203347215.png)

点击新增，填写任务信息

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130501625.png" alt="image-20240318130501625" style="zoom:50%;" />

高级配置的其它配置项稍后在分片广播章节详细解释。

 

添加成功，启动任务

![image-20240318130551255](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130551255.png)

通过日志查看任务运行情况

![image-20240318130608832](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130608832.png)

下边启动媒资管理的service工程，启动执行器。

观察执行器方法的执行。

![image-20240318130655394](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130655394.png)

如果要停止任务需要在调度中心操作

![image-20240318130708805](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130708805.png)

任务跑一段时间注意清理日志

![image-20240318130722290](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130722290.png)

xxl路由策略配置详细内容：[xxl-job（四）路由策略_xxl-job路由策略-CSDN博客](https://blog.csdn.net/w_t_y_y/article/details/117119864)

## 分片广播

掌握了xxl-job的基本使用，下边思考如何进行分布式任务处理呢？如下图，我们会启动多个执行器组成一个集群，去执行任务。

![image-20240318130800270](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318130800270.png)

执行器在集群部署下调度中心有哪些调度策略呢？

查看xxl-job官方文档，阅读高级配置相关的内容：

高级配置：
   \- 路由策略：当执行器集群部署时，提供丰富的路由策略，包括；
       FIRST（第一个）：固定选择第一个机器；
       LAST（最后一个）：固定选择最后一个机器；
       ROUND（轮询）：；
       RANDOM（随机）：随机选择在线的机器；
       CONSISTENT_HASH（一致性HASH）：每个任务按照Hash算法固定选择某一台机器，且所有任务均匀散列在不同机器上。
       LEAST_FREQUENTLY_USED（最不经常使用）：使用频率最低的机器优先被选举；
       LEAST_RECENTLY_USED（最近最久未使用）：最久未使用的机器优先被选举；
       FAILOVER（故障转移）：按照顺序依次进行心跳检测，第一个心跳检测成功的机器选定为目标执行器并发起调度；
       BUSYOVER（忙碌转移）：按照顺序依次进行空闲检测，第一个空闲检测成功的机器选定为目标执行器并发起调度；
       SHARDING_BROADCAST(分片广播)：广播触发对应集群中所有机器执行一次任务，同时系统自动传递分片参数；可根据分片参数开发分片任务；

   \- 子任务：每个任务都拥有一个唯一的任务ID(任务ID可以从任务列表获取)，当本任务执行结束并且执行成功时，将会触发子任务ID所对应的任务的一次主动调度，通过子任务可以实现一个任务执行完成去执行另一个任务。
   \- 调度过期策略：
       忽略：调度过期后，忽略过期的任务，从当前时间开始重新计算下次触发时间；
       立即执行一次：调度过期后，立即执行一次，并从当前时间开始重新计算下次触发时间；
   \- 阻塞处理策略：调度过于密集执行器来不及处理时的处理策略；
       单机串行（默认）：调度请求进入单机执行器后，调度请求进入FIFO队列并以串行方式运行；
       丢弃后续调度：调度请求进入单机执行器后，发现执行器存在运行的调度任务，本次请求将会被丢弃并标记为失败；
       覆盖之前调度：调度请求进入单机执行器后，发现执行器存在运行的调度任务，将会终止运行中的调度任务并清空队列，然后运行本地调度任务；
   \- 任务超时时间：支持自定义任务超时时间，任务运行超时将会主动中断任务；
   \- 失败重试次数；支持自定义任务失败重试次数，当任务失败时将会按照预设的失败重试次数主动进行重试；

下边要重点说的是分片广播策略，分片是指是调度中心以执行器为维度进行分片，将集群中的执行器标上序号：0，1，2，3...，广播是指每次调度会向集群中的所有执行器发送任务调度，请求中携带分片参数。

如下图：

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131022846.png" alt="image-20240318131022846" style="zoom:50%;" />

每个执行器收到调度请求同时接收分片参数。

xxl-job支持动态扩容执行器集群从而动态增加分片数量，当有任务量增加可以部署更多的执行器到集群中，调度中心会动态修改分片的数量。

**作业分片适用哪些场景呢？**

- 分片任务场景：10个执行器的集群来处理10w条数据，每台机器只需要处理1w条数据，耗时降低10倍；

- 广播任务场景：广播执行器同时运行shell脚本、广播集群节点进行缓存更新等。

所以，广播分片方式不仅可以充分发挥每个执行器的能力，并且根据分片参数可以控制任务是否执行，最终灵活控制了执行器集群分布式处理任务。

**使用说明：**

**分片广播** 和普通任务开发流程一致，不同之处在于可以获取分片参数进行分片业务处理。

Java语言任务获取分片参数方式：

BEAN、GLUE模式(Java)，可参考Sample示例执行器中的示例任务

下边测试作业分片：

1. 定义作业分片的任务方法

```Java
/**
  * 2、分片广播任务
  */
@XxlJob("shardingJobHandler")
public void shardingJobHandler() throws Exception {
    // 分片参数
    int shardIndex = XxlJobHelper.getShardIndex();
    int shardTotal = XxlJobHelper.getShardTotal();
    log.info("分片参数：当前分片序号 = {}, 总分片数 = {}", shardIndex, shardTotal);
    log.info("开始执行第"+shardIndex+"批任务");
}
```

2. 在调度中心添加任务

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131421838.png" alt="image-20240318131421838" style="zoom:50%;" />

添加成功:

![image-20240318131506343](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131506343.png)

启动任务，观察日志

下边启动两个执行器实例，观察每个实例的执行情况

首先在nacos中配置media-service的本地优先配置：

```yaml
spring:
 cloud:
  config:
    override-none: true
```

将media-service启动两个实例

两个实例的在启动时注意端口不能冲突：

实例1 在VM options处添加：-Dserver.port=63051 -Dxxl.job.executor.port=9998

实例2 在VM options处添加：-Dserver.port=63050 -Dxxl.job.executor.port=9999

![image-20240318131735660](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131735660.png)

启动两个实例

观察任务调度中心，稍等片刻执行器有两个

![image-20240318131753744](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131753744.png)

两示例日志如下:

![image-20240318131828536](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131828536.png)

![image-20240318131840898](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240318131840898.png)

从日志可以看每个实例的分片序号不同。

如果其中一个执行器挂掉，只剩下一个执行器在工作，稍等片刻调用中心发现少了一个执行器将动态调整总分片数为1。

到此作业分片任务调试完成，此时我们可以思考：

> 当一次分片广播到来，各执行器如何根据分片参数去分布式执行任务，保证执行器之间执行的任务不重复呢？
