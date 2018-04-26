---
layout: post
title: Kubernetes系列3：使用Helm在Kubernetes上部署Zookeeper
category: 未分类
---

# 安装步骤
```
# 添加repo
$ helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator

# 安装zookeeper
$ helm install --set resources.requests.memory=200Mi,servers=2 --name myzk incubator/zookeeper

# 进入bash
$ kubectl exec -it myzk-zookeeper-0 -- /bin/bash
```

# 集群内部访问
```
# 写数据
$ kubectl exec myzk-zookeeper-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar

# 读数据
$ kubectl exec myzk-zookeeper-0 -- /opt/zookeeper/bin/zkCli.sh get /foo

# 交互式命令行
$ kubectl exec -it myzk-zookeeper-0 -- /opt/zookeeper/bin/zkCli.sh

[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper, foo]
```

# 集群外部访问
通过port-forward方式
```
$ kubectl port-forward myzk-zookeeper-0 2181:2181

$ zkCli.sh

[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper, foo]
```

# Zookeeper在Kuberneters上的组件
首先查看一下Zookeeper应用
```
$ kubectl get all -l app=zookeeper

NAME                   READY     STATUS    RESTARTS   AGE
pod/myzk-zookeeper-0   1/1       Running   0          2m
pod/myzk-zookeeper-1   1/1       Running   0          1m

NAME                              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/myzk-zookeeper            ClusterIP   10.107.169.140   <none>        2181/TCP            2m
service/myzk-zookeeper-headless   ClusterIP   None             <none>        2888/TCP,3888/TCP   2m

NAME                              DESIRED   CURRENT   AGE
statefulset.apps/myzk-zookeeper   2         2         2m
```

可以看到Kuberneters为Zookeeper创建了以下几个组件：
1. `statefulsets.apps/myzk-zookeeper` 是Chart创建的StatefulSet
2. `pod/myzk-zookeeper-<0|1|2>` 是StatefulSet创建的Pod，每个Pod是运行Zookeeper Server的容器
3. `service/myzk-zookeeper-headless`是Chart创建的Headless Service，为了Zookeeper集群内部节点的网络通信
4. `service/myzk-zookeeper` 是为Zookeeper Client访问集群创建的Service

## StatefulSet
StatefulSet 是为了解决有状态服务的问题（对应 Deployments 和 ReplicaSets 是为无状态服务而设计），其应用场景包括：
- 稳定的持久化存储，即 Pod 重新调度后还是能访问到相同的持久化数据，基于 PVC 来实现
- 稳定的网络标志，即 Pod 重新调度后其 PodName 和 HostName 不变，基于 Headless Service（即没有 Cluster IP 的 Service）来实现
- 有序部署，有序扩展，即 Pod 是有顺序的，在部署或者扩展的时候要依据定义的顺序依次依序进行（即从 0 到 N-1，在下一个 Pod 运行之前所有之前的 Pod 必须都是 Running 和 Ready 状态），基于 init containers 来实现
- 有序收缩，有序删除（即从 N-1 到 0）

从上面的应用场景可以发现，StatefulSet 由以下几个部分组成：
- 用于定义网络标志（DNS domain）的 Headless Service
- 用于创建 PersistentVolumes 的 volumeClaimTemplates
- 定义具体应用的 StatefulSet

StatefulSet 中每个 Pod 的 DNS 格式为 statefulSetName-{0..N-1}.serviceName.namespace.svc.cluster.local，本例中两个NDS分别为：
- myzk-zookeeper-0.myzk-zookeeper-headless.default.svc.cluster.local
- myzk-zookeeper-1.myzk-zookeeper-headless.default.svc.cluster.local

本例zookeeper的StatefulSet定义如下：
```
# Source: zookeeper/templates/statefulset.yaml
apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: myzk-zookeeper
  labels:
    app: "zookeeper"
    chart: "zookeeper-0.6.4"
    release: "myzk"
    heritage: "Tiller"
spec:
  serviceName: myzk-zookeeper-headless
  replicas: 3
  updateStrategy:
    type: OnDelete

  template:
    metadata:
      labels:
        app: "zookeeper"
        release: "myzk"
    spec:
      containers:
      - name: zookeeper-server
        imagePullPolicy: Always
        image: gcr.io/google_samples/k8szk:v2
        resources:
          limits:
            cpu: 1
            memory: 4Gi
          requests:
            cpu: 500m
            memory: 2Gi

        ports:
        - containerPort: 2181
          name: client
        - containerPort: 2888
          name: server
        - containerPort: 3888
          name: leader-election
      env:
        - name : ZK_REPLICAS
          value: "3"
        - name : ZK_HEAP_SIZE
          value: "2G"
        - name : ZK_TICK_TIME
          value: "2000"
        - name : ZK_INIT_LIMIT
          value: "10"
        - name : ZK_SYNC_LIMIT
          value: "5"
        - name : ZK_MAX_CLIENT_CNXNS
          value: "60"
        - name: ZK_SNAP_RETAIN_COUNT
          value: "3"
        - name: ZK_PURGE_INTERVAL
          value: "1"
        - name: ZK_LOG_LEVEL
          value: INFO
        - name: ZK_CLIENT_PORT
          value: "2181"
        - name: ZK_SERVER_PORT
          value: "2888"
        - name: ZK_ELECTION_PORT
          value: "3888"
        command:
        - sh
        - -c
        - zkGenConfig.sh && exec zkServer.sh start-foreground
        readinessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          exec:
            command:
            - "zkOk.sh"
          initialDelaySeconds: 15
          timeoutSeconds: 5
        volumeMounts:
        - name: datadir
          mountPath: /var/lib/zookeeper
          subPath: data
          volumeClaimTemplates:
            - metadata:
                name: datadir
              spec:
                accessModes: [ "ReadWriteOnce" ]
                resources:
                  requests:
                    storage: 5Gi
```

```
$ kubectl get service myzk-zookeeper
NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
myzk-zookeeper   ClusterIP   10.107.169.140   <none>        2181/TCP   1h

$ kubectl get statefulset myzk-zookeeper
NAME             DESIRED   CURRENT   AGE
myzk-zookeeper   2         2         1h

# 根据 volumeClaimTemplates 自动创建 PVC
$ kubectl get pvc
NAME                       STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
datadir-myzk-zookeeper-0   Bound     pvc-88c86cb8-490b-11e8-a576-4a314017421a   5Gi        RWO            standard       1h
datadir-myzk-zookeeper-1   Bound     pvc-97fc6850-490b-11e8-a576-4a314017421a   5Gi        RWO            standard       1h

# 查看创建的 Pod，他们都是有序的
$ kubectl get pods -l app=zookeeper
NAME               READY     STATUS    RESTARTS   AGE
myzk-zookeeper-0   1/1       Running   0          1h
myzk-zookeeper-1   1/1       Running   0          1h

# 使用 nslookup 查看这些 Pod 的 DNS
$ kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh
/ # nslookup myzk-zookeeper-0.myzk-zookeeper-headless.default.svc.cluster.local
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      myzk-zookeeper-0.myzk-zookeeper-headless.default.svc.cluster.local
Address 1: 172.17.0.4 myzk-zookeeper-0.myzk-zookeeper-headless.default.svc.cluster.local
```

## Headless Service
Headless服务是指不需要Cluster IP的服务，在创建服务的时候指定 spec.clusterIP=None，包括两种类型：
- 不指定 Selectors，但设置 externalName，通过 CNAME 记录处理
- 指定 Selectors，通过 DNS A 记录设置后端 endpoint 列表

```
# Source: zookeeper/templates/service-headless.yaml
apiVersion: v1
kind: Service
metadata:
  name: myzk-zookeeper-headless
  labels:
    app: "zookeeper"
    chart: "zookeeper-0.6.4"
    release: "myzk"
    heritage: "Tiller"
spec:
  ports:
  - port: 2888
    name: server
  - port: 3888
    name: leader-election
  clusterIP: None
  selector:
    app: "zookeeper"
    release: "myzk"
```

本例采用的是Selectors的方式，生成的域名分别为：
- myzk-zookeeper-0.myzk-zookeeper-headless.default.svc.cluster.local
- myzk-zookeeper-1.myzk-zookeeper-headless.default.svc.cluster.local


那么zookeeper的几个节点是如何互相发现的呢？

启动节点前首先会执行zkGenConfig.sh脚本，打印所有服务器列表到Zookeeper的配置文件zoo.cfg
```
function print_servers() {
         for (( i=1; i<=$ZK_REPLICAS; i++ ))
        do
                echo "server.$i=$NAME-$((i-1)).$DOMAIN:$ZK_SERVER_PORT:$ZK_ELECTION_PORT"
        done
}
```

```
#This file was autogenerated by k8szk DO NOT EDIT
clientPort=2181
dataDir=/var/lib/zookeeper/data
dataLogDir=/var/lib/zookeeper/log
tickTime=2000
initLimit=10
syncLimit=5
maxClientCnxns=60
minSessionTimeout= 4000
maxSessionTimeout= 40000
autopurge.snapRetainCount=3
autopurge.purgeInteval=1
server.1=myzk-zookeeper-0.myzk-zookeeper-headless.default.svc.cluster.local:2888:3888                                                                                   
server.2=myzk-zookeeper-1.myzk-zookeeper-headless.default.svc.cluster.local:2888:3888
```

## Client Service
为了能让客户端连接到zookeeper集群，需要创建一个服务
```
# Source: zookeeper/templates/service-clients.yaml
apiVersion: v1
kind: Service
metadata:
  name: myzk-zookeeper
  labels:
    app: "zookeeper"
    chart: "zookeeper-0.6.4"
    release: "myzk"
    heritage: "Tiller"
spec:
  ports:
  - port: 2181
    name: client
  selector:
    app: "zookeeper"
    release: "myzk"
```

## PodDisruptionBudget
通过PodDisruptionBudget确保Zookeeper有一半以上节点存活

```
# Source: zookeeper/templates/poddisruptionbudget.yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: myzk-zookeeper
  labels:
    app: "zookeeper"
    chart: "zookeeper-0.6.4"
    release: "myzk"
    heritage: "Tiller"
spec:
  selector:
    matchLabels:
      app: "zookeeper"
      release: "myzk"
  minAvailable: 2
```

# 参考
- [Charts Zookeeper](https://github.com/kubernetes/charts/tree/master/incubator/zookeeper)
- [Kubernetes 指南](https://kubernetes.feisky.xyz/zh/) -- feisky的gitbook
