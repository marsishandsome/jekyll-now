---
layout: post
title: Kubernetes系列1：使用Minikube在Kubernetes中运行应用
category: Kubernetes
---

本文主要介绍：
1. 如何在mac系统上安装minikube集群
2. 如何在kubernetes上部署管理应用

# 创建Minikube集群
## 1. 安装Docker for Mac
[Docker 官方文档](https://docs.docker.com/docker-for-mac/install/#install-and-run-docker-for-mac)

## 2. 安装VirtualBox
使用Homebrew安装VitrualBox
```
$ brew cask install virtualbox
```

## 3. 安装Minikube
使用curl下载并安装最新版本Minikube
```
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 && \
  chmod +x minikube && \
  sudo mv minikube /usr/local/bin/
```

## 4. 安装minikube的xhyve driver (for mac)
使用Homebrew安装[xhyve驱动程序](https://github.com/machine-drivers/docker-machine-driver-xhyve#install)并设置其权限
```
$ brew install docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
$ sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
$ sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

## 5. 安装kubectl
使用Homebrew下载kubectl命令管理工具
```
$ brew install kubectl
```

## 6. 启动Minikube集群
```
$ minikube start --vm-driver=xhyve
```
## 7. 设限环境变量
本文使用Minikube，而不是将Docker镜像push到registry，可以使用与Minikube VM相同的Docker主机构建镜像，以使镜像自动存在。为此，请确保使用Minikube Docker守护进程：
```
$ eval $(minikube docker-env)
```

## 8. 设置Minikube环境
可以在~/.kube/config文件中查看所有可用的环境 。
```
$ kubectl config use-context minikube
```

## 9. 验证kubectl配置：
```
$ kubectl cluster-info
```

## 10. 打开Dashboard
```
$ minikube dashboard
```

# 创建Node.js应用程序
将这段代码保存在一个名为hellonode的文件夹中，文件名server.js:
```js
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello World!');
};
var www = http.createServer(handleRequest);
www.listen(8080);
```

运行应用：
```
$ node server.js
```
在 http://localhost:8080 中查看。

# 创建Docker容器镜像
## 1. 创建Dockerfile
在hellonode文件夹中创建一个Dockerfile命名的文件
```
FROM node:6.9.2
EXPOSE 8080
COPY server.js .
CMD node server.js
```

## 2. 构建Docker镜像
```
$ eval $(minikube docker-env)
$ docker build -t hello-node:v1 .
```

# 创建Deployment
## 1. 创建Depolyment
一个Pod可以是一个容器，也可以是多个容器的组合，本例中的Pod只有一个容器。Kubernetes会为Deployment生成Pod，并且会检查Pod的健康状况，如果它终止，则重新启动一个Pod的容器，通过Deployment来管理Pod的创建和扩展。

使用kubectl run命令创建Deployment来管理Pod
```
$ kubectl run hello-node --image=hello-node:v1 --port=8080
```

## 2. 查看
查看Deployment
```
$ kubectl get deployments
NAME         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-node   1         1         1            1           22h
```

查看所有Pod
```
$ kubectl get pods
NAME                          READY     STATUS    RESTARTS   AGE
hello-node-658d8f6754-vklw4   1/1       Running   1          22h
```

在Pod中执行bash命令
```
$ kubectl exec hello-node-658d8f6754-vklw4 ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4332   656 ?        Ss   00:31   0:00 /bin/sh -c node server.js
root         5  0.0  1.2 679976 25568 ?        Sl   00:31   0:00 node server.js
root        11  0.0  0.0  17496  2020 ?        Rs   06:49   0:00 ps aux
```

查看Pod详情
```
kubectl describe pod hello-node-658d8f6754-vklw4
```

查看Pod日志
```
kubectl logs  hello-node-658d8f6754-vklw4
```

查看群集events
```
kubectl get events
```

查看kubectl配置
```
kubectl config view
```

# 创建Service
## 1. 创建Service
默认情况，这Pod只能通过Kubernetes群集内部IP访问。要使hello-node容器从Kubernetes虚拟网络外部访问，须要使用Kubernetes Service暴露Pod。

使用kubectl expose命令将Pod暴露到外部环境
```
$ kubectl expose deployment hello-node --type=LoadBalancer
```

## 2. 查看Service
```
$ kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.103.43.207   <pending>     8080:30908/TCP   22h
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          23h
```

## 3. 访问Service
通过--type=LoadBalancer flag来在群集外暴露Service，在支持负载均衡的云提供商上，将配置外部IP地址来访问Service。在Minikube上，该LoadBalancer type使服务可以通过minikube Service命令访问。
```
$ minikube service hello-node
```

该命令将打开浏览器，访问node应用

## 4. 查看日志
Pod日志查看方式
```
$ kubectl logs <POD-NAME>
```

# 更新应用程序
## 1. 编辑server.js文件以返回新消息
```
response.end('Hello World Again!');
```

## 2. build新版本镜像
```
$ eval $(minikube docker-env)
$ docker build -t hello-node:v2 .
```

## 3. Deployment更新镜像
```
$ kubectl set image deployment/hello-node hello-node=hello-node:v2
```

## 4. 再次运行应用以查看新消息
```
$ minikube service hello-node
```

# 清理删除
## 1. 删除Service
```
$ kubectl delete service hello-node
```

## 2. 删除Deployment
```
$ kubectl delete deployment hello-node
```

## 3. 停止minikube
```
$ minikube stop
```

# 参考
- [Hello Minikube](https://kubernetes.io/docs/tutorials/stateless-application/hello-minikube/) -- Kubernetes官方文档
- [使用Minikube在Kubernetes中运行应用](http://docs.kubernetes.org.cn/126.html) -- Kubernetes中文社区
- [Kubernetes 指南](https://kubernetes.feisky.xyz/zh/) -- feisky的gitbook
