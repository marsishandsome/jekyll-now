---
layout: post
title: Kubernetes系列2：Kubernetes的应用管理器Helm
category: Kubernetes
---

如果把Kubernetes看做一个分布式操作系统，势必需要一个Kubernetes的应用管理器，类似于yum/apt/homebrew，Helm就是这么一款为Kubernetes打造的应用管理器。

# 基本使用
## 1. 安装Helm客户端
Mac系统 (其它系统[参考](https://docs.helm.sh/using_helm/#installing-helm)
)
```
$ brew install kubernetes-helm
```

## 2. 安装Helm服务器端
通过helm的init命令可以在Kubernetes集群上安装Helm服务器Tiller，需要事先配置好kubectl
```
$ helm init

# 该命令会在集群内部部署一个tiller服务
$ kubectl get pods --namespace=kube-system
NAME                                    READY     STATUS    RESTARTS   AGE
tiller-deploy-df4fdf55d-8fssp           1/1       Running   5          1d
```

## 3. 更新charts列表
Charts是Kubernetes的软件包
```
$ helm repo update
```

# 部署MySQL服务
## 1. 安装MySQL
```
$ helm install --name my-release \
 --set mysqlRootPassword=secretpassword,mysqlUser=my-user,mysqlPassword=my-password,mysqlDatabase=my-database \
   stable/mysql
```

## 访问MySQL
```
$ MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
export POD_NAME=$(kubectl get pods --namespace default -l "app=my-release-mysql" -o jsonpath="{.items[0].metadata.name}")
MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default my-release-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)
kubectl port-forward $POD_NAME 3306:3306
mysql -h ${MYSQL_HOST} -P${MYSQL_PORT} -u root -p${MYSQL_ROOT_PASSWORD}

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| my-database        |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
```

# Helm工作原理
Helm有三个基本概念：
1. Chart: Helm的应用，类似于YUM RPM，包含了该应用所有Kubernetes manifest模板
2. Repository：Helm package存储仓库，类似于YUM Repo
3. Release：Chart的部署实例，每个Chart可以部署多个release

Helm包含两个部分：
1. Helm客户端：是一个命令行工具，负责管理charts，它通过gPRC API向tiller发送请求，并由tiller来管理对应的Kubernetes资源。
2. Helm服务器端Tiller：接收来自helm客户端的请求，并把相关资源的操作发送到Kubernetes，负责管理（安装、查询、升级或删除等）和跟踪Kubernetes资源。为了方便管理，Tiller把release的相关信息保存在kubernetes的ConfigMap中。

# Helm Charts
Helm使用[Charts](https://github.com/kubernetes/charts)来管理Kubernetes manifest文件。每个chart都至少包括:
- 应用的基本信息 Chart.yaml
- 一个或多个 Kubernetes manifest 文件模版（放置于 templates / 目录中），可以包括 Pod、Deployment、Service 等各种 Kubernetes 资源

## 依赖管理
Helm 支持两种方式管理依赖的方式：
- 直接把依赖的 package 放在 charts/ 目录中
- 使用requirements.yaml 并用helm dep up foochart来自动下载依赖的packages

例如：[charts/incubator/kafka/requirements.yaml](https://github.com/kubernetes/charts/blob/master/incubator/kafka/requirements.yaml)
```
dependencies:
- name: zookeeper
  version: 0.5.0
  repository: https://kubernetes-charts-incubator.storage.googleapis.com/
  condition: zookeeper.enabled
```

## Charts模板
Charts模板基于Go template和[Sprig](https://github.com/Masterminds/sprig)

# Helm基本命令
## 查询 charts
```
$ helm search
$helm search mysql
```

## 查询 package 详细信息
```
$ helm inspect stable/mysql
```

## 部署 package
```
$ helm install stable/mysql
```
部署之前可以自定义 package 的选项：
```
# 查询支持的选项
$ helm inspect values stable/mysql

# 自定义 password
$ echo "mysqlRootPassword: passwd" > config.yaml
$ helm install -f config.yaml stable/mysql
```
另外，还可以通过打包文件（.tgz）或者本地 package 路径（如 path/foo）来部署应用。

## 查询服务 (Release) 列表
```
$ helm ls
NAME            REVISION        UPDATED                         STATUS          CHART           NAMESPACE
my-release      1               Wed Apr 25 17:32:37 2018        DEPLOYED        mysql-0.4.0     default
```

## 查询服务 (Release) 状态
```
$ helm status my-release
LAST DEPLOYED: Wed Apr 25 17:32:37 2018
NAMESPACE: default                                                
STATUS: DEPLOYED        

RESOURCES:
==> v1/PersistentVolumeClaim                                 
NAME              STATUS  VOLUME                                    CAPACITY  ACCESS MODES  STORAGECLASS  AGE                                                           
my-release-mysql  Bound   pvc-9749f056-486b-11e8-a576-4a314017421a  8Gi       RWO           standard      17h

==> v1/Service                                                             
NAME              TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)   AGE
my-release-mysql  ClusterIP  10.102.193.199  <none>       3306/TCP  17h

==> v1beta1/Deployment
NAME              DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
my-release-mysql  1        1        1           1          17h

==> v1/Pod(related)
NAME                               READY  STATUS   RESTARTS  AGE
my-release-mysql-7f5666b6dc-t8zx6  1/1    Running  0         17h

==> v1/Secret
NAME              TYPE    DATA  AGE
my-release-mysql  Opaque  2     17h

==> v1/ConfigMap
NAME                   DATA  AGE
my-release-mysql-test  1     17h


NOTES:                                                        
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
my-release-mysql.default.svc.cluster.local

To get your root password run:                                  

    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace default my-release-mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

To connect to your database:       

1. Run an Ubuntu pod that you can use as a client:

    kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il

2. Install the mysql client:

    $ apt-get update && apt-get install mysql-client -y                                

3. Connect using the mysql cli, then provide your password:
    $ mysql -h my-release-mysql -p

To connect to your database directly from outside the K8s cluster:                                                                                  
    MYSQL_HOST=127.0.0.1
    MYSQL_PORT=3306         

    # Execute the following commands to route the connection:
    export POD_NAME=$(kubectl get pods --namespace default -l "app=my-release-mysql" -o jsonpath="{.items[0].metadata.name}")
    kubectl port-forward $POD_NAME 3306:3306                                    

    mysql -h ${MYSQL_HOST} -P${MYSQL_PORT} -u root -p${MYSQL_ROOT_PASSWORD}
```

## 升级和回滚 Release
```
# 升级
$ echo "mysqlRootPassword: passwd" > config.yaml
$ helm upgrade -f config.yaml my-release stable/mysql

# 回滚
$ helm rollback my-release 1
```

升级完发现root密码没有修改！

## 删除 Release
```
# 删除release
$ helm delete my-release

# 删除数据
$ helm delete --purge my-release
```

## repo 管理
```
# 查询 repo 列表
$ helm repo list

# 添加 incubator repo
$ helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
```

## chart 管理
```
# 创建一个新的 chart
$ helm create chart-hello-world

# validate chart
$ helm lint

# 打包 chart 到 tgz
$ helm package chart-hello-world
```

# Helm插件：helm-template (Debug/render templates client-side)
在客户端实例化chart组件

[Github主页](https://github.com/technosophos/helm-template)

```
# 安装helm-template插件
$ helm plugin install https://github.com/technosophos/helm-template

# 下载charts代码
$ git clone https://github.com/kubernetes/charts.git

# 生成zookeeper实例
$ cd charts/incubator
$ helm template --name myzk zookeeper
```

# 参考
- [Helm Github](https://github.com/kubernetes/helm)
- [Helm Quick Start](https://docs.helm.sh/using_helm/#quickstart)
- [Charts Github](https://github.com/kubernetes/charts/)
- [Helm -- feisky的gitbook](https://kubernetes.feisky.xyz/zh/apps/helm.html)
