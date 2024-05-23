# 1. 安装jdk环境

## 1.1 下载jdk8

下载linux版本的`jdk8`

链接：https://pan.baidu.com/s/1nG6WdZwl11K-sEnzDNcNRg 
提取码：teds

## 1.2 安装jdk8

上传到linux中的/var中

![image-20240522144225556](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240522144225556.png)

```shell
# 进入/usr/local/lib
cd /usr/local/lib

# 创建java文件夹
mkdir java

# 给予文件夹权限
chmod 7777 java

# 回到/opt目录
cd /opt

# 将jdk压缩包解压到刚才创建的目录
tar -zxvf jdk-8u144-linux-x64.tar.gz -C /usr/local/lib/java
```
接下来修改环境变量
```shell
# 修改环境变量
vi /etc/profile
```

然后在最底下加入

```
export JAVA_HOME=/usr/local/lib/java/jdk1.8.0_144
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export  PATH=${JAVA_HOME}/bin:$PATH
```

`如果你的jdk不是我提供的连接下载的，请根据自己的情况修改环境变量和解压的文件名`

## 1.3 验证安装是否成功

安装结束后查询jdk版本

输入命令

```shell
java -version
```

![image-20240522144948457](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240522144948457.png)

安装成功

# 2. 安装maven

## 2.1 去官网下载maven

![image-20240521134942977](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240521134942977.png)

下载完成后上传到linux中，这里选择的是`/opt`路径

![image-20240521135108643](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240521135108643.png)

## 2.2 解压maven包

输入命令

```shell
tar -zxvf apache-maven-3.9.6-bin.tar.gz
```

然后将文件移动到/usr/local/文件夹下进行管理

```shell
mv apache-maven-3.9.6 /usr/local/
```

## 2.3 配置环境变量

打开环境变量文件

```shell
vi /etc/profile
```

在文件末尾添加上

```text
export MAVEN_HOME=/usr/local/apache-maven-3.9.6
export PATH=$MAVEN_HOME/bin:$PATH
```

## 2.4 刷新配置文件

输入命令

```shell
source /etc/profile
```

## 2.5 配置maven镜像仓库

输入命令

```shell
# 打开maven的配置文件
vi /usr/local/apache-maven-3.9.6/conf/settings.xml 
```

找到`</mirrors>`，将如下内容覆盖原`<mirror>`文件

```
<mirror>
      <id>alimaven</id>
      <name>aliyun maven</name>
      <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
      <mirrorOf>central</mirrorOf>
</mirror>
```

![image-20240521135623944](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240521135623944.png)

## 2.6 创建阿里云云效

**如果你不需要依赖本地特有的依赖，可以跳过这一小节**

首先我们进入这个网站[阿里云云效_云效_云原生时代新DevOps平台-阿里云 (aliyun.com)](https://www.aliyun.com/product/yunxiao)

注册完成后

先点击左上角，再点击制品仓库进入下个页面

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240522145950602.png" alt="image-20240522145950602" style="zoom:25%;" />

此处我们选择非生产仓库

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240522150030157.png" alt="image-20240522150030157" style="zoom:33%;" />

接下来按照它的提示添加推送和拉取的配置

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240522150110886.png" alt="image-20240522150110886" style="zoom:33%;" />

根据刚才我们配置的maven

输入命令

```sh
vi /usr/local/apache-maven-3.9.6/conf/settings.xml 
```

根据提示进行配置

注意，当你添加完配置后，需要在如图位置添加上你刚才创建的配置的ID，否则它不会生效。

如图配置`activeProfiles`,我的两个配置ID分别是`rdc`和`aliyun-Devops`

<img src="https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240522150205565.png" alt="image-20240522150205565" style="zoom:33%;" />

之后，如果你有本地想要上传的包或者想从服务器上拉取的包，都可以脱离本地而使用了。

jenkins在构建时也可以使用这些配置

## 2.6 验证是否成功

```shell
mvn -v
```

![image-20240521135730882](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/image-20240521135730882.png)



# 3. docker部署jenkins

## 3.1 拉取镜像

输入命令

这个命令会从Docker Hub拉取最新的Jenkins长期支持（LTS）版本的镜像。

新版本兼容问题较好，老版本很多插件都会安装失败。

```shell
docker pull jenkins/jenkins:lts
```

## 3.3 创建并启动`Jenkins`容器

以下使用`docker-compose`构建，请自行下载

docker-compose文件内容如下

```
version: '3.8'
# 执行脚本；docker-compose -f docker-compose-v1.0.yml up -d
services:
  jenkins:
    image: jenkins/jenkins:2.439
    container_name: jenkins
    privileged: true
    user: root
    ports:
      - "9090:8080"
      - "50001:50000"
    volumes:
      - /data/jenkins_home:/var/jenkins_home # 如果不配置到云服务器路径下，则可以配置 jenkins_home 会创建一个数据卷使用
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/local/bin/docker
      - /usr/local/apache-maven-3.9.6/conf/settings.xml:/usr/local/maven/conf/settings.xml 
		# 这里只提供了 maven 的 settings.xml 主要用于修改 maven 的镜像地址
      - /usr/local/lib/java/jdk1.8.0_144:/usr/local/jdk1.8.0_144 # 提供了 jdk1.8，如果你需要其他版本也可以配置使用。
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false # 禁止安装向导「如果需要密码则不要配置」docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    restart: unless-stopped

volumes:
  jenkins_home:
```

注意`- /data/jenkins_home:/var/jenkins_home # 如果不配置到云服务器路径下，则可以配置 jenkins_home 会创建一个数据卷使用`

如果你没有`/data/jenkins_home`，请自行创建。

## 3.3 后续

之后的部分可以查看小傅哥的网站学习

[Jenkins | 小傅哥 bugstack 虫洞栈](https://bugstack.cn/md/road-map/jenkins.html)