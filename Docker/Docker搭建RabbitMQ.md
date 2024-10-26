# 1. 下载镜像

```bash
docker pull rabbitmq:management
```

不选择latest标签是因为启动后无法直接访问它的管理后台，需要额外设置

# 2. 启动指令

```bash
docker run -d --name=my_rabbitmq \
  -p 5671:5671 \
  -p 5672:5672 \
  -p 4369:4369 \
  -p 15671:15671 \
  -p 15672:15672 \
  -p 25672:25672 \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=admin \
  rabbitmq:management
```

1. **5672**: RabbitMQ 的 AMQP 协议端口，用于客户端与 RabbitMQ 进行通信。
2. **15672**: RabbitMQ 管理插件的 Web 管理界面端口，用于通过浏览器访问管理界面。
3. **5671**: RabbitMQ 的 AMQP 协议端口，用于客户端与 RabbitMQ 进行加密通信（TLS/SSL）。如果你需要启用 TLS/SSL，可以使用这个端口。
4. **4369**: Erlang 端口映射守护进程（epmd）端口，用于 Erlang 节点发现和通信。在 RabbitMQ 集群中，节点之间使用这个端口进行通信。
5. **15671**: RabbitMQ 管理插件的 Web 管理界面端口，用于通过浏览器访问管理界面（TLS/SSL）。如果你需要启用 TLS/SSL 的管理界面，可以使用这个端口。
6. **25672**: Erlang 分布式端口，用于 RabbitMQ 节点之间的内部通信。在 RabbitMQ 集群中，节点之间使用这个端口进行通信。

其他端口通常在特定场景下使用，例如集群通信、Erlang 分布式通信等。如果不需要这些额外的端口，可以只映射上述两个端口。

简化后指令如下

```bash
docker run -d --name=my_rabbitmq \
  -p 5672:5672 \
  -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=admin \
  -e RABBITMQ_DEFAULT_PASS=admin \
  rabbitmq:management
```

