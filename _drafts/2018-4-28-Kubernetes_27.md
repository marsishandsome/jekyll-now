---
layout: post
title: Kubernetes系列5：服务发现
category: Kubernetes
---

- Service：直接用Service提供cluster内部的负载均衡，并借助cloud provider提供的LB提供外部访问
- Ingress Controller：还是用Service提供cluster内部的负载均衡，但是通过自定义LB提供外部访问
- Service Load Balancer：把load balancer直接跑在容器中，实现Bare Metal的Service Load Balancer
- Custom Load Balancer：自定义负载均衡，并替代kube-proxy，一般在物理部署Kubernetes时使用，方便接入公司已有的外部服务

# kube-proxy


# 参考
- [Kubernetes 指南 - 服务发现与负载均衡](https://kubernetes.feisky.xyz/zh/concepts/service.html) -- by Feisky
- [Kubernetes Handbook - Service](https://jimmysong.io/kubernetes-handbook/concepts/service.html) -- by Jimmy Song
