# 一、本章诉求

搭建一个 ChatGPT-SDK 组件工程，专门用于封装对 OpenAI 接口的使用。由于 OpenAI 接口本身较多，并有各类配置的设置，所以开发一个共用的 SDK 组件，更合适我们在各类工程中扩展使用。所以我们这个章节以 OpenAI 抽象为会话模型，建立工程结构设计。**其实这也是架构设计的一部分**。并在本章的 ChatGPT-SDK 组件工程中，开发简单的对话功能模块实现。

# 二、流程设计

整个流程为；以会话模型为出口，驱动整个服务的调用链路。并对外提供会话工厂的创建和使用。

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240516105658399.png" alt="image-20240516105658399" style="zoom:50%;" />

# 三、使用的依赖

1. Retrofit是一个类型安全的HTTP客户端，它是用于Android和Java的。它的主要功能是将HTTP API转化为Java接口。

   Retrofit使用注解来描述HTTP请求，参数和请求方法可以在接口中定义。  

   Retrofit提供了以下功能： 

   - URL参数替换和查询参数支持。
   - 对象转换为请求体（例如，JSON，协议缓冲区）。
   - Multipart请求体和文件上传。
   - HTTP响应转换为Java对象。
   - 连接到Web服务器的同步阻塞调用和异步非阻塞调用。