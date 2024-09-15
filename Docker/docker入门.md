# 1.Docker是什么

引用[菜鸟教程](https://www.runoob.com/docker/docker-tutorial.html)中的话

> Docker 是一个开源的应用容器引擎，基于 [Go 语言](https://www.runoob.com/go/go-tutorial.html) 并遵从 Apache2.0 协议开源。
>
> Docker 可以让开发者打包他们的应用以及依赖包到一个轻量级、可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。
>
> 容器是完全使用沙箱机制，相互之间不会有任何接口（类似 iPhone 的 app）,更重要的是容器性能开销极低。
>
> Docker 从 17.03 版本之后分为 CE（Community Edition: 社区版） 和 EE（Enterprise Edition: 企业版），我们用社区版就可以了。

# 2. 安装Docker

# 2.1 安装

以下使用的是阿里云购置的99元服务器，配置是2C2G，操作系统是ubuntu 22.04

我们可以输入以下指令来安装docker，稍等片刻即可安装完毕

```bash
 curl -fsSL https://test.docker.com -o test-docker.sh
 sudo sh test-docker.sh
```

首先设置环境路径

```bash
export PATH=$PATH:/usr/bin/docker
```

设置完毕后输入，启动docker

```bash
sudo systemctl start docker
```

之后输入设置开机自启

```bash
sudo systemctl enable docker
```

此时输入`docker`，即可看到

![image-20240915193705599](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240915193705599.png)

## 2.2切换国内源

此时可能在拉取一些镜像的时候速度不够快，我们可以切换国内源来解决，不过最好的情况还是在网络环境良好的情况下拉取国外源，更加全面

首先输入

```bash
vi /etc/docker/daemon.json
```

然后在其中输入

```json
{
    "registry-mirrors": [
        "https://do.nark.eu.org",
        "https://dc.j8.work",
        "https://docker.m.daocloud.io",
        "https://dockerproxy.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://docker.nju.edu.cn"
    ]
}                              
```

保存后输入

```bash
systemctl daemon-reload
systemct restart docker
```

之后输入

```bash
docker info
```

即可看到如下内容

![image-20240915200758241](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240915200758241.png)

# 3. 构建一个镜像

## 3.1 本地测试

我接下来将通过将一个go项目的打包成镜像并运行来展示一次简易的流程。

我们新建一个go项目，然后写入如下内容，再执行`go run`指令

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func hello(w http.ResponseWriter, req *http.Request) {
	_, err := fmt.Fprintf(w, "Hello, Wwh!\n")
	if err != nil {
		return
	}
}

func add(w http.ResponseWriter, req *http.Request) {
	number1 := req.URL.Query().Get("number1")
	number2 := req.URL.Query().Get("number2")
	_, err := fmt.Fprintf(w, "result = "+(number1+number2))
	if err != nil {
		return
	}
}
func main() {
	http.HandleFunc("/hello", hello)
	http.HandleFunc("/add", add)
	log.Fatal(http.ListenAndServe("0.0.0.0:8000", nil))
}
```

运行起来后我们测试一下hello接口
```bash
> curl http://localhost:8000/hello
Hello, Wwh!
```

再测试一下add接口

```bash
> curl http://localhost:8000/add\?number1\=1\&number2\=2
result = 12%
```

可以看到接口正常工作

## 3.2 开始打包

然后我们现在需要在同个目录下编写`Dockerfile`来打包镜像

```dockerfile
# 使用 golang:alpine 作为构建镜像
FROM golang:alpine AS builder

# 设置工作目录
WORKDIR /workspace

# 复制源代码
COPY . .

# 编译 Go 应用程序
RUN go build -o main .

# 使用 alpine:3.19 镜像作为最终镜像
FROM alpine:3.19

# 设置工作目录
WORKDIR /workspace

# 复制编译好的二进制文件
COPY --from=builder /workspace/main /workspace/main

# 设置入口点
ENTRYPOINT ["/workspace/main"]
```

然后我们在当前目录输入

```bash
docker build -t go-example .
```

- **`docker build`**：这是 Docker 命令，用于构建 Docker 镜像。
- **`-t go-example`**：`-t` 选项用于指定镜像的名称和标签。`go-example` 是镜像的名称，`.` 是标签（通常为 `latest`）。
- **`.`**：这是上下文路径，表示 Docker 构建镜像时使用的上下文目录。`.` 表示当前目录。

稍等片刻即可完成打包

我们输入`docker images`

可以查看刚才打好的镜像

![image-20240915201108364](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240915201108364.png)

# 4. 运行镜像

在终端输入

```bash
docker run -d -p 6666:8000 go-example 
```

- **`docker run`**：这是 Docker 命令，用于运行一个新的容器。
- **`-d`**：`-d` 选项表示在后台（detached mode）运行容器，即容器在后台运行，不会占用当前终端。
- **`-p 6666:8000`**：`-p` 选项用于端口映射。`6666:8000` 表示将容器的 `8000` 端口映射到主机的 `6666` 端口。
- **`go-example`**：这是要运行的 Docker 镜像的名称。

然后我们输入`docker ps`查看运行中的镜像

![image-20240915201313161](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240915201313161.png)

可以看到镜像正常运行，我们将服务器的端口对外开放，然后使用curl方式试一下

```bash
> curl http://47.93.83.136:6666/add\?number1\=233\&number2\=666
result = 233666
```

```bash
> curl http://47.93.83.136:6666/hello
Hello, Wwh!
```

OK！运行成功！

上述两个接口对于公网也是开放的，欢迎体验。