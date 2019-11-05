---
layout: post
title: Docker on Mac初体验
category: Docker
---

## 在Docker中运行Bash
### 安装
```
$ brew cask install docker
```

### 下载镜像
```
$ docker pull daocloud.io/library/centos:6

$ docker images
```

### Docker中运行Bash
```
$ docker run --rm -i -t --name test daocloud.io/library/centos:6 /bin/bash
```

## 基本命令

### 启动命令
```
# 启动容器，退出的时候容器停止，但是不删除
$ docker run -ti --name container_name image_name command

# 启动容器，退出的时候容容器自动删除
$ docker run --rm -ti --name container_name image_name command

# 端口映射，容器内部的8080端口映射成外部的80端口
$ docker run --rm -ti p 8080:80 --name container_name image_name command
```

### 退出命令
```
# 杀死所有正在运行的容器
$ docker kill $(docker ps -q)

# 删除所有停止的容器
$ docker rm $(docker ps -a -q)

# 删除所有未保存的镜像
$ docker rmi $(docker images -q -f dangling=true)
```

### 和容器进行交互
```
# 在容器中运行命令
$ docker exec -ti container_name command

# 在容器中运行bash + 自适应屏幕宽度
$ docker exec -ti -e LINES=$(tput lines) -e COLUMNS=$(tput cols) container_name /bin/bash

# 查看容器日志
$ docker logs -ft container_name

# 把容器保存成镜像
$ docker commit -m "commit_message"  -a "author" container_name username/image_name:tag
```

## 打造自己的镜像
### 保存容器为镜像
```
# 启动容器
$ docker run -i -t --name test daocloud.io/library/centos:6 /bin/bash

# 在容器里安装软件
> yum install ...

# 把容器保存成镜像
$ docker commit -m "my_first_docker_image"  -a "author" test author/test:latest

# 查看生成的镜像
$ docker images
```

### Dockerfile

#### 编写Dockerfile
```
$ mkdir -p spark-dev/base
$ vi spark-dev/base/Dockerfile
```

```
FROM daocloud.io/library/centos:6

RUN yum install -y \
java-1.7.0-openjdk.x86_64 \
openssh-server

RUN curl \
http://d3kbcqa49mib13.cloudfront.net/spark-2.0.0-bin-hadoop2.7.tgz \
| tar -xzC /opt
RUN ln -s /opt/spark-2.0.0-bin-hadoop2.7 /opt/spark

ENV SPARK_HOME /opt/spark
ENV PATH $SPARK_HOME:$PATH
```

#### 把Dockerfile编译成镜像
```
$ docker build -t spark-dev-base spark-dev/base/
```

#### 使用编译好的镜像
```
$ docker run --rm -ti --name spark-dev-base spark-dev-base /bin/bash

> /opt/spark/bin/spark-shell --master local[*]
```

源码见：[https://github.com/marsishandsome/spark-docker](https://github.com/marsishandsome/spark-docker)

## 参考
- [Docker for Mac官方文档](https://docs.docker.com/docker-for-mac/)
- [Docker Resource All in One](https://github.com/hangyan/docker-resources/blob/master/README_zh.md)
- [Docker Spark](https://github.com/sequenceiq/docker-spark)
- [Docker Cheat Sheet](http://zeroturnaround.com/wp-content/uploads/2016/03/Docker-cheat-sheet-by-RebelLabs.png)
- [Docker Quick Ref](https://github.com/dimonomid/docker-quick-ref)
