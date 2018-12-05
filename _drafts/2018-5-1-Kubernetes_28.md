---
layout: post
title: Kubernetes系列8：部署Kafka
category: Kubernetes
---
# 修改代码
```
edit incubator/kafka/templates/statefulset.yaml
- name: KAFKA_ZOOKEEPER_CONNECT
  #value: {{ include "zookeeper.url" . | quote }}
  value: "my-kafka-zookeeper-0.my-kafka-zookeeper-headless.default.svc.cluster.local:2181"
```

# 安装Helm客户端
```
wget https://kubernetes-helm.storage.googleapis.com/helm-v2.8.2-linux-amd64.tar.gz
tar zxvf helm-v2.8.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
```

# 安装Chart本地仓库
```
git clone https://github.com/kubernetes/charts.git
cd charts
helm package incubator/zookeeper

mkdir -p incubator/kafka/charts
cp zookeeper-0.6.4.tgz incubator/kafka/charts/
cp -r incubator/zookeeper/ incubator/kafka/charts
helm package incubator/kafka
helm repo index .
helm serve
```

# 安装Tiller
```
$ cat rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""


$ kubectl create -f rbac-config.yaml

$ helm init \
--service-account tiller \
 --upgrade --stable-repo-url http://127.0.0.1:8879
```

# 安装Kafka
```
$ helm delete my-kafka; helm del --purge my-kafka

$ helm install --name my-kafka \
--set persistence.enabled=false \
stable/kafka
```

# 测试zookeeper
```
$ kubectl exec my-kafka-zookeeper-0 -- /opt/zookeeper/bin/zkCli.sh create /foo bar

kubectl exec -it my-kafka-zookeeper-0 -- /bin/bash
kubectl exec -it my-kafka-kafka-0 -- /bin/bash

kubectl run -i --tty --image busybox dns-test --restart=Never --rm /bin/sh
kubectl run -it --image confluentinc/cp-kafka:4.0.1-1 test-kafka --restart=Never -- /bin/bash
kubectl run -it --image gcr.io/google_samples/k8szk:v2 test-zookeeper --restart=Never -- /bin/bash

# 测试连接zk
kubectl run -it --image gcr.io/google_samples/k8szk:v2 test-zookeeper --restart=Never -- /bin/bash
kubectl exec -it my-kafka-zookeeper-1 -- /bin/bash
zkCli.sh -server my-kafka-zookeeper:2181 # 有时可以有时不行
zkCli.sh -server my-kafka-zookeeper-0.my-kafka-zookeeper-headless:2181  ok
zkCli.sh -server my-kafka-zookeeper-0.my-kafka-zookeeper-headless.default.svc.cluster.local:2181  ok


cub zk-ready my-kafka-zookeeper:2181 40
cub zk-ready my-kafka-zookeeper-0.my-kafka-zookeeper-headless.default.svc.cluster.local:2181 40
cub zk-ready my-kafka-zookeeper-0.my-kafka-zookeeper.default.svc.cluster.local:2181 40
cub zk-ready "$KAFKA_ZOOKEEPER_CONNECT" "${KAFKA_CUB_ZK_TIMEOUT:-40}"

```

# 在Kafka节点访问
```
# 进入kafka节点
$ kubectl exec -it my-kafka-kafka-0 -- /bin/bash

# 创建topic
kafka-topics \
--zookeeper my-kafka-zookeeper-0.my-kafka-zookeeper-headless.default.svc.cluster.local:2181 \
--create --replication-factor 3 --partitions 1 --topic test

# 获取topic
kafka-topics \
--zookeeper my-kafka-zookeeper-0.my-kafka-zookeeper-headless.default.svc.cluster.local:2181 \
--list
```

# 在集群内部访问
```
apiVersion: v1
kind: Pod
metadata:
  name: kafka-client-test
  namespace: default
spec:
  containers:
  - name: kafka
    image: solsson/kafka:0.11.0.0
    command:
      - sh
      - -c
      - "exec tail -f /dev/null"
```

```
kubectl exec -ti kafka-client-test -- ./bin/kafka-topics.sh \
--zookeeper my-kafka-zookeeper-0.my-kafka-zookeeper-headless.default.svc.cluster.local:2181 \
--list
```

# 集群外部访问Kafka

# 参考
- [利用Helm简化Kubernetes应用部署](https://yq.aliyun.com/articles/159601)
- [Kafka for Charts](https://github.com/kubernetes/charts/tree/master/incubator/kafka)
- [Kubernetes Kafka K8SKafka](https://github.com/kubernetes/contrib/tree/master/statefulsets/kafka)
