# Git

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/gitlogo.png)



#  版本管理工具概念

在平时开发中,可能有时要用到上个版本的内容,例如:

> 领导让写文档,写好了,领导让修改,改好了,领导觉得第一版不错,改回来吧,此时内心一脸懵,第一版长啥样没存档啊

实际上,代码开发中也需要这样的软件来管理我们的代码. 例如我们经常会碰到如下的现象:

> 改之前好好的,改完就报错了,也没怎么修改啊

在这种情况下如果不能查看修改之前的代码,查找问题是非常困难的.

如果有一个软件能记录我们对文档的所有修改,所有版本,那么上面的问题讲迎刃而解.而这类软件我们一般叫做版本控制工具

版本管理工具一般具有如下特性:

> 能够记录历史版本,回退历史版本
> 团队开发,方便代码合并


#  主流版本管理工具介绍 

## Git

工作流程

```text
Git是分布式版本控制系统（Distributed Version Control System，简称 DVCS），分为两种类型的仓库：
本地仓库和远程仓库
工作流程如下
    1．从远程仓库中克隆或拉取代码到本地仓库(clone/pull)
    2．从本地进行代码修改
    3．在提交前先将代码提交到暂存区
    4．提交到本地仓库。本地仓库中保存修改的各个历史版本
    5．修改完成后，需要和团队成员共享代码时，将代码push到远程仓库
```

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/git.png)

Windows下载地址: [Git - Downloading Package (git-scm.com)](https://git-scm.com/download/win)

Linux/Unix下载方法: [Git (git-scm.com)](https://git-scm.com/download/linux)

#  Git工作流程

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/git%E6%B5%81%E7%A8%8B.png)



#  命令行--git基本操作

### 环境配置

1. 打开Git Bash
2. 设置用户信息

邮箱可以是假邮箱

```bash
git config --global user.name “wwhds”

git config --global user.email “hello@wwhds.cn”
```

3. 查看配置信息

```shell
git config --global user.name

git config --global user.email
```

### 为常用指令配置别名

有些常用的指令参数非常多，每次都要输入好多参数，我们可以使用别名。

#### 如何定义和使用别名

要定义 Git 的别名，请使用 `git config` 命令，加上别名和要替换的命令。例如，要为 `git push` 创建别名 `p`：

```shell
$ git config --global alias.p 'push'
```

你可以通过将别名作为 `git` 的参数来使用别名，就像其他命令一样：

```shell
$ git p
```

要查看所有的别名，用 `git config` 列出你的配置：

```shell
$ git config --global -l
user.name=ricardo
user.email=ricardo@example.com
alias.p=push
```

无论使用哪种方法，定义别名都能改善你使用 Git 的整体体验。更多关于定义 Git 别名的信息，请看《[Git Book](https://link.zhihu.com/?target=https%3A//git-scm.com/book/en/v2/Git-Basics-Git-Aliases)》。

#### 有用的 Git 别名

1. **Git 单行日志**

   以单行方式显示你的提交，使输出更紧凑：

   ```shell
   git config --global alias.ll 'log --pretty=oneline --all --graph --abbrev-commit'
   ```

   - `--pretty=oneline`: 将每个提交的信息压缩为一行，只显示提交的哈希值和提交信息。
   - `--all`: 显示所有分支的提交历史记录，包括本地分支和远程分支。
   - `--graph`: 以图形化的方式显示提交历史记录，显示分支、合并等关系。
   - `--abbrev-commit`: 缩短每个提交的哈希值为7个字符，减少显示的字符数，方便查看。

   使用这个别名可以提供所有提交的简短列表：

   ```shell
   $ git ll
   * ea12179 (HEAD -> master, origin/master) 导出运营数据报表 后端开发结束
   * 96f64fd 数据统计功能开发
   * 8fba9e4 用户催单和接单提醒功能开发
   * 8c96623 地址簿相关功能开发 管理端订单功能开发 用户端订单功能开发 微信支付模拟xxxxxxxxxx * ea12179 (HEAD -> master, origin/master) 导出运营数据报表 后端开发结束* 96f64fd 数据统计功能开发* 8fba9e4 用户催单和接单提醒功能开发* 8c96623 地址簿相关功能开发 管理端订单功能开发 用户端订单功能开发 微信支付模拟$ git ll33559c5 (HEAD -> master) Another commit17646c1 test1
   ```

2. **Git 的最近一次提交**

   这将显示你最近一次提交的详细信息。这是扩展了《Git Book》中 [别名](https://link.zhihu.com/?target=https%3A//git-scm.com/book/en/v2/Git-Basics-Git-Aliases) 一章的例子：

   ```shell
   $ git config --global alias.last 'log -1 HEAD --stat'
   ```

   用它来查看最后的提交：

   ```shell
   $ git last
   commit f3dddcbaabb928f84f45131ea5be88dcf0692783 (HEAD -> branch1)
   Author: ricardo <ricardo@example.com>
   Date:   Tue Nov 3 00:19:52 2020 +0000
   
       Commit to branch1
   
    test2 | 1 +
    test3 | 0
    2 files changed, 1 insertion(+)
   ```

3. **Git 远程仓库**

   `git remote -v` 命令列出了所有配置的远程仓库。用别名 `rv` 将其缩短：

   ```shell
   $ git config --global alias.rv 'remote -v'
   ```

4. **Git 配置列表**

   `gl` 别名可以更方便地列出所有用户配置：

   ```shell
   $ git config --global alias.gl 'config --global -l'
   ```

   现在可以查看用户配置了

   ```shell
   user.name=Wwhds
   user.email=a1605691832@163.com
   core.quotepath=false
   alias.ll=log --pretty=oneline --all --graph --abbrev-commit
   alias.last=log -1 HEAD --stat
   alias.rv=remote -v
   alias.gl=config --global -l
   ```

### 解决GitBash乱码问题

1. 打开GitBash执行下面命令

```shell
git config --global core.quotepath false
```

2. ${git_home}/etc/bash.bashrc 文件最后加入下面两行

```shell
export LANG="zh_CN.UTF-8" 
export LC_ALL="zh_CN.UTF-8"
```

### 获取本地仓库

要使用Git对我们的代码进行版本控制，首先需要获得本地仓库

1. 在电脑的任意位置创建一个空目录（例如test）作为我们的本地Git仓库

2. 进入这个目录中，点击右键打开Git bash窗口

3. 执行命令git init

4. 如果创建成功后可在文件夹下看到隐藏的.git目录。

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/git_init.png)

### 基础操作指令

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/git_work.png)

#### 查看修改状态 (status)

```shell
$ git status
```

不同文件状态不同

- Untracked files 新创建的文件是未跟踪状态
- Changes to be committed 即将被提交
- Changes not staged for commit 修改并未添加至暂存区来提交
- nothing to commit,working tree clean 提交后显示没有东西可以提交

```shell
On branch master
Changes not staged for commit:                                
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   file01.txt
Untracked files:                                                             
  (use "git add <file>..." to include in what will be committed)
        file02.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

#### 添加工作区到暂存区(add)

```shell
$ git add .
```

- 作用：添加工作区一个或多个文件的修改到暂存区

将暂存区指定文件回退

```shell
$ git reset "文件名"
```

将暂存区全部文件回退

```shell
$ git reset
```

#### 提交暂存区到本地仓库(commit)

```shell
$ git commit -m '注释内容'
```

- 作用：提交暂存区汇总所有内容到本地仓库的当前分支
- 命令形式：git commit -m ‘注释内容’

#### 查看提交日志(log)

在4.2.2中设置了git log的别名并添加设置。

我们使用别名即可:

```shell
$ git ll
```

效果如下:

```shell
* 34fa638 (HEAD -> master) file01
```

若想获得更详细的信息:

```shell
$ git log
```

效果如下:

```shell
commit 34fa638efcb9fbe96b997a0cab2fe2dd73f8f15b (HEAD -> master)
Author: Wwhds <a1605691832@163.com>
Date:   Wed Feb 7 15:26:15 2024 +0800

    file01

```

提交时候添加的备注会被放到日志中

#### 版本回退

撤回到之前的某个操作，他回去删除我们撤回到位置之后的版本

- 作用：版本切换
- 命令形式：git reset --hard commitID
  - commitID 可以使用 git-log 或 git log 指令查看
- 如何查看已经删除的记录？
  - git reflog
  - 这个指令可以看到已经删除的提交记录

我们可以在reflog里面知道删除文件的id，我们可以直接使用命令git reset --hard commitID 还原

所以

git reset --hard commitID既可以做版本回退，也可以做版本还原

#### 添加文件至忽略列表

一般我们总会有些文件无需纳入Git 的管理，也不希望它们总出现在未跟踪文件列表。 通常都是些自动

生成的文件，比如日志文件，或者编译过程中创建的临时文件等。 在这种情况下，我们可以在工作目录

中**创建一个名为 .gitignore 的文件（文件名称固定），列出要忽略的文件模式**。

下面是一个示例：

先创建一个.gitignore文件

```shell
$ touch .gitignore
```

然后使用vi指令对.gitignore文件进行编辑

> 在其中插入*.txt

那么之后的提交便会无视.txt后缀的文件

#### 基础操作指令练习

1. 新建一个文件夹在其中初始化git仓库

```shell
$ git init
```

2. 创建file01.txt并在其中写入"12345"

```shell
$ touch file01.txt
$ vi file01.txt
```

3. 查看工作目录状态

```shell
$ git status
```

此时我们会看到:

```
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        file01.txt

nothing added to commit but untracked files present (use "git add" to track)
```

4. 将file01.txt加入暂存区

```shell
$ git add .
```

5. 将暂存区的file01.txt提交到本地仓库

```shell
$ git commit -m 'file01.txt'
```

6. 修改file01.txt内容为"23333"并提交到本地仓库

```shell
$ git add .
$ git commit -m 'file01.txt update'
```

7. 利用别名查看日志

```shell
$ git ll
```

8. 回退到第一次提交的版本

```shell
$  git reset a8c40cb --hard
```

### 分支

几乎所有的版本控制系统都以某种形式支持分支。 使用分支意味着你可以把你的工作从开发主线上分离

开来进行重大的Bug修改、开发新的功能，以免影响开发主线。master是我们的主线

每个人开发的那一部分就是一个分支，使得每个人的开发互不影响，在每个人都开发完后就将所有的代码汇总到一起，此时就要执行分支的合并操作

工作区只能在一个分支工作，每个分支存放的文件或者资源是不一样的，就相当于不同的文件夹

#### 查看本地分支

```shell
$ git branch
```

带星号的表示当前分支

#### 创建本地分支(branch)

```shell
$ git branch "分支名"
```

创建的新分支会建立在当前分支的版本之上，所以新建的分支会有当前分支的内容

#### 切换分支(checkout)

```shell
$ git checkout
```

我们还可直接切换到一个不存在的分支（创建并切换)

```shell
$ git checkout -b
```

#### 合并分支(merge)

```shell
$ git merge "分支名"
```

注意：分支上的内容必须先提交,才能切换分支

一个分支上的提交可以合并到另一个分支

在每个人都开发完后就将所有的代码汇总到一起，此时就要执行分支的合并操作

当分支岔开时表示多个人在修改同一个文件

#### 删除分支

**不能删除当前分支，只能删除其他分支**

```shell
git branch -d b1 删除分支时，需要做各种检查
git branch -D b1 不做任何检查，强制删除
```

#### 解决冲突

当我们合并分支后，两个或者多个分支对同一个文件的同一个地方进行修改的时候（不是同一个地方是不会出现冲突的 ），此时git就不知道要取哪个分支修改的值，是取a分支修改的值，还是取b分支修改的值呢，此时就产生了冲突

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/%E5%86%B2%E7%AA%81%E6%8A%A5%E9%94%99.png)

冲突时文件具体内容如下:

![](https://wwhds-markdown-image.oss-cn-beijing.aliyuncs.com/%E5%86%B2%E7%AA%81%E5%85%B7%E4%BD%93%E6%83%85%E5%86%B5.png)

第一个count值表示的是当前分支修改的值

第二个count值是在dev分支修改的值

当两个分支上对文件的修改可能会存在冲突，例如同时修改了同一个文件的同一行，这时就需要手动解

决冲突，**解决冲突步骤如下：**

其实我们就是直接手动去删除文件中的一个分支，留下一个分支，这样就不会冲突了

1. 处理文件中冲突的地方
2. 将解决完冲突的文件加入暂存区(add)
3. 提交到仓库(commit)

#### 开发中分支使用原则与流程

几乎所有的版本控制系统都以某种形式支持分支。 使用分支意味着你可以把你的工作从开发主线上分离

开来进行重大的Bug修改、开发新的功能，以免影响开发主线。

在开发中，一般有如下分支使用原则与流程：

- master （生产） 分支

 线上分支，主分支，中小规模项目作为线上运行的应用对应的分支；

- develop（开发）分支

 是从master创建的分支，一般作为开发部门的主要开发分支，如果没有其他并行开发不同期上线

 要求，都可以在此版本进行开发，阶段开发完成后，需要是合并到master分支,准备上线。

> 例如我们要开发新功能，我们要可以在develop分支上在建一个分支，新功能一般叫做feature分支，开发完以后在合并到 develop分支上面去，而不是直接提交到master分支，最后项目做完了develop在合并到master分支上

develop和master分支是不可删除的

- feature/xxxx分支（用完可删）

 从develop创建的分支，一般是同期并行开发，但不同期上线时创建的分支，分支上的研发任务完

 成后合并到develop分支，用完后可删除。

- hotfifix/xxxx分支，

 从master派生的分支，一般作为线上bug修复使用，修复测试完成后需要合并到master、test、develop分支。

- 还有一些其他分支，在此不再详述，例如test分支（用于代码测试）、pre分支（预上线分支）等等。
