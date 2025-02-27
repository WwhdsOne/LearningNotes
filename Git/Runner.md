
# 1. 获取GITHUB仓库设置

1. 首先我们创建一个github仓库，然后点击这里

  ![image-20250227145622998](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227145622998.png)

2. 创建一个自己主持的runner

   ![image-20250227150013534](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227150013534.png)

3. 点击后会进入到一个有相关教程的网页，我们需要选择对应的平台

   ![image-20250227150100951](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227150100951.png)

4. 获取身份和仓库信息

   ![image-20250227150220336](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227150220336.png)

5. 编写入口点脚本文件

   ```sh
   #!/bin/sh
   
   
   # 调整 Docker 套接字权限
   if [ -e /var/run/docker.sock ]; then
       echo "Adjusting permissions for /var/run/docker.sock..."
       sudo chmod 666 /var/run/docker.sock
   else
       echo "Docker socket (/var/run/docker.sock) not found!"
       exit 1
   fi
   
   
   # 检查必要的环境变量
   if [ -z "$GITHUB_REPOSITORY_URL" ] || [ -z "$GITHUB_RUNNER_TOKEN" ]; then
       echo "Error: GITHUB_REPOSITORY_URL and GITHUB_RUNNER_TOKEN environment variables are required."
       exit 1
   fi
   
   # 配置 runner
   ./config.sh --url "$GITHUB_REPOSITORY_URL" --token "$GITHUB_RUNNER_TOKEN"
   
   # 启动 runner
   ./run.sh
   ```

   为了实现DID(Docker in Docker) 我们需要为之后将要挂载的docker.sock提供足够的权限，这样在容器内部也可以操纵外部的docker

   环境变量则是会从环境变量读取并替换为上一步获取到的仓库URL和仓库TOKEN
   
# 2. 构建GITHUB-Runner镜像

官方镜像网址:https://github.com/actions/runner-images

官方镜像的环境较为齐全，但是体积较大，所以我选择自制镜像

```dockerfile
# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置环境变量，避免交互提示
ENV DEBIAN_FRONTEND=noninteractive

# 替换为阿里云镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 更新源并安装必要的依赖、libicu 和 Docker CLI
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libicu66 \
        sudo \
        curl \
        ca-certificates \
        tar \
        apt-transport-https \
        gnupg-agent \
        gnupg \
        software-properties-common \
    && curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add - \
    && add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 创建非 root 用户
RUN useradd -m -s /bin/bash runner
# 给 runner 用户添加 sudo 权限
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 切换到非 root 用户
USER runner
# 设置工作目录为 runner 用户的家目录
WORKDIR /home/runner

# 从本地复制下载好的压缩包到容器内
COPY --chown=runner:runner actions-runner-linux-x64-2.322.0.tar.gz .

# 解压并删除压缩包
RUN tar xzf actions-runner-linux-x64-2.322.0.tar.gz \
    && rm actions-runner-linux-x64-2.322.0.tar.gz

# 安装依赖（根据实际情况调整，Ubuntu 可能需要不同步骤）
# 这里假设 installdependencies.sh 脚本在 Ubuntu 也适用
# RUN ls
RUN sudo ./bin/installdependencies.sh

# 复制入口点脚本
COPY --chown=runner:runner entrypoint.sh .
RUN chmod +x entrypoint.sh


# 定义入口点
ENTRYPOINT ["./entrypoint.sh"]
```

> 以下内容是对于上述部分指令的解释

1. 安装docker依赖

   ```dockerfile
   apt-get install -y docker-ce-cli
   ```

   其中安装必要的依赖和Docker-Cli是因为DID(Docker in Docker)需要容器内有相关Docker依赖可以操作宿主机的docker

2. 切换用户

     ```dockerfile
     # 切换到非 root 用户
     USER runner
     # 设置工作目录为 runner 用户的家目录
     WORKDIR /home/runner
     ```

     切换到非root用户是因为`actions-runner-linux-x64-2.322.0.tar.gz`中的脚本因为安全原因不允许使用sudo指令执行脚本，所以不能使用root用户

3. 入口点脚本

   ```dockerfile
   COPY --chown=runner:runner entrypoint.sh .
   RUN chmod +x entrypoint.sh
   ```

   这部分脚本内容用于以后对不同的github仓库复用，在获取github仓库设置部分会详细讲解

4. 下载runner压缩包

   ```dockerfile
   # 从本地复制下载好的压缩包到容器内
   COPY --chown=runner:runner actions-runner-linux-x64-2.322.0.tar.gz .
   
   # 解压并删除压缩包
   RUN tar xzf actions-runner-linux-x64-2.322.0.tar.gz \
       && rm actions-runner-linux-x64-2.322.0.tar.gz
   ```

   这一部分的压缩包可以使用如下指令进行下载

   ```shell
   curl -L -o actions-runner-linux-x64-2.322.0.tar.gz https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-linux-x64-2.322.0.tar.gz
   ```

# 3. 启动镜像

```dockerfile
docker run -d \
  -e GITHUB_REPOSITORY_URL="YOUR_REPOSITORY_URL" \
  -e GITHUB_RUNNER_TOKEN="YOUR_REPOSITORY_TOKEN" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  github-runner
```

启动后输入`docker logs YOUR CONTAINER_NAME`可以看到如下内容

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227164837411.png" alt="image-20250227164837411" style="zoom:50%;" />

看到`Runner successfully added`则为启动成功，我们可以去github仓库验证一下

再次回到Runner页面我们可以看到一个空闲的Runner

![image-20250227164954284](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227164954284.png)

# 4. 项目设置

接下来我将创建一个GO项目并推送来验证runner

1. 目录结构

   <img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227165336523.png" alt="image-20250227165336523" style="zoom:50%;" />

   - `.github/workflows`中的`build.yml`是Runner会执行的操作
   - `Dockerfile`使用本地`alpine:latest`镜像可以构建出轻量级的镜像

2. 工作流文件如下

   ```yaml
   name: TestPipeline
   
   on:
     push:
       branches:
         - main
   
   jobs:
     build:
       runs-on: self-hosted
       env:
         IMAGE_NAME: myapp
         CONTAINER_NAME: myapp
       steps:
         # 用于拉取代码
         - name: Check out repository code
           uses: actions/checkout@v4
         # 设置GO语言环境
         - name: Set up Go 1.24
           uses: actions/setup-go@v5
           with:
             go-version: '1.24'
             # 自建Runner需要关闭缓存，否在会报错
             # 在issue https://github.com/actions/setup-go/issues/403 提及
             cache: false
   
         - name: Update Go dependencies
           run: |
             export GOPROXY=https://goproxy.cn,direct
             go get -u
   
         - name: Build Go application
           run: CGO_ENABLED=0 GOOS=linux go build -p 2 -ldflags "-w -s" -trimpath -gcflags "all=-l" -o myapp
   
         - name: Check for existing Docker container
           run: |
             # 检查名为${{ env.CONTAINER_NAME }}的容器是否正在运行
             if docker ps --filter name=${{ env.CONTAINER_NAME }} --format "{{.Names}}" | grep -q${{ env.CONTAINER_NAME ]]; then
               # 如果容器正在运行，则停止并移除它
               docker stop ${{ env.CONTAINER_NAME }}
               docker rm ${{ env.CONTAINER_NAME }}
             fi
   
         - name: Check for existing Docker image
           run: |
             # 检查名为${{ env.IMAGE_NAME }}的镜像是否存在
             if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${{ env.IMAGE_NAME }}:latest"; then
               # 如果镜像存在，则移除它
               docker rmi ${{ env.IMAGE_NAME }}:latest
             fi
   
         - name: Build Docker image
           run: |
             # 使用 Dockerfile 构建镜像，并指定镜像名称为${{ env.IMAGE_NAME }}
             docker build -t ${{ env.IMAGE_NAME }}:latest .
   
         - name: Run Docker container
           run: |
             # 启动新镜像的容器，指定容器名称为${{ env.CONTAINER_NAME }}，使用 --network host 模式并后台运行
             docker run -d --network host --name ${{ env.CONTAINER_NAME }} ${{ env.IMAGE_NAME }}:latest
   ```

   - `actions/checkout@v4`的项目地址:https://github.com/actions/checkout
   - `actions/setup-go@v5`除了go语言还有各种其他的语言环境，可以在github上搜索得到，关键字***action setup***

3. Dockerfile

   ```dockerfile
   # 使用 alpine:latest 作为基础镜像
   FROM alpine:latest
   
   # 创建应用目录
   RUN mkdir -p /app
   
   # 将编译好的二进制文件复制到容器的 /app 目录下
   COPY myapp /app/myapp
   
   # 设置工作目录
   WORKDIR /app
   
   # 设置容器启动时执行的命令
   CMD ["/app/myapp"]
   ```

   这部分内容较为简单，不多解释

4. 代码部分

   ```go
   package main
   
   import (
   	"net/http"
   
   	"github.com/gin-gonic/gin"
   )
   
   func main() {
   	// 创建一个默认的Gin引擎
   	r := gin.Default()
   
   	// 定义一个GET请求的路由，路径为"/"
   	r.GET("/", func(c *gin.Context) {
   		c.JSON(http.StatusOK, gin.H{
   			"message": "Hello, World!",
   		})
   	})
   
   	// 默认在8080端口启动服务器
   	r.Run()
   }

​	当向这个应用发送GET请求时会得到**Hello,World!**的响应

# 5. 推送代码 

​	推送后我们可以在仓库点击这里查看工作流流程

![image-20250227172744233](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227172744233.png)

效果如下

![image-20250227172937623](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227172937623.png)

验证

我们可以去主机上查看是否有对应容器和镜像

![image-20250227173123665](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227173123665.png)

可以看到镜像构建成功同时容器也成功启动

我们发送请求来验证一下

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20250227173221399.png" alt="image-20250227173221399" style="zoom:50%;" />

大功告成！
