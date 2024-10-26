# 1. 安装rsyslog

```bash
sudo apt-get install rsyslog
```

# 2. 修改配置

![image-20241023173131543](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20241023173131543.png)

去除原本这两行的注释

## 3. 重启rsyslog服务

```bash
systemctl restart rsyslog
```

# 4. 发送测试日志

```bash
logger -n localhost -p info "LOL"
```

# 5. 查看结果

```bash
tail -f /var/log/syslog
```

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20241023173313011.png" alt="image-20241023173313011" style="zoom:50%;" />