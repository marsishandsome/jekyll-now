# Distributed System Links
- [一共81个，开源大数据处理工具汇总（上）](http://www.36dsj.com/archives/24852)
- [一共81个，开源大数据处理工具汇总（下）](http://www.36dsj.com/archives/25042)
- [“分布式机器学习的故事”系列分享](http://cxwangyi.github.io/notes/2014-01-20-distributed-machine-learning.html)
- [后Hadoop时代的大数据架构](http://zhuanlan.zhihu.com/donglaoshi/19962491?from=timeline&isappinstalled=0) -- 董飞
- [Apache YARN/Mesos与Google Borg差距多远？](http://mp.weixin.qq.com/s?__biz=MjM5NzAyNTE0Ng==&mid=207442842&idx=1&sn=c23b157e68ca5bd9654b395dc4362eef&scene=0#rd)


### CAP定理 (Eric Brewer)
- [Wikipedia](CAP theorem)
- [You Can’t Sacrifice Partition Tolerance](http://codahale.com/you-cant-sacrifice-partition-tolerance/)

In theoretical computer science, the CAP theorem, also known as Brewer's theorem, states that it is impossible for a distributed computer system to simultaneously provide all three of the following guarantees:
1. Consistency (all nodes see the same data at the same time)
2. Availability (a guarantee that every request receives a response about whether it succeeded or failed)
3. Partition tolerance (the system continues to operate despite arbitrary message loss or failure of part of the system)


### Kubernetes


### Petuum
- [官网](http://petuum.github.io/)
- [Github](https://github.com/petuum/public)
- [Wiki](https://github.com/petuum/public/wiki)
- [Petuum: A New Platform for Distributed Machine Learning on Big Data](http://arxiv.org/pdf/1312.7651v2.pdf)


# Cluster Management
- [Why the data center needs an operating system](http://radar.oreilly.com/2014/12/why-the-data-center-needs-an-operating-system.html)

### 对比
- [mesos, omega, borg: a survey](http://www.umbrant.com/blog/2015/mesos_omega_borg_survey.html)
- [Docker, Mesos, Marathon, and the End of Pets](http://blog.factual.com/docker-mesos-marathon-and-the-end-of-pets)
- [全方位对比Mesos、Omega和Borg](http://www.infoq.com/cn/articles/comparison-of-mesos-omega-and-borg)

### mesos
- [Mesos: A Platform for Fine-Grained Resource Sharing in the Data Center](https://www.cs.berkeley.edu/~alig/papers/mesos.pdf)

### Omega
- [Omega: flexible, scalable schedulers for large compute clusters](http://research.google.com/pubs/pub41684.html)
- [论文](http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/41684.pdf)

### Borg
- [Large-scale cluster management at Google with Borg](http://static.googleusercontent.com/media/research.google.com/en/us/pubs/archive/43438.pdf) -- 论文
- [Cluster Management at Google](http://www.infoq.com/presentations/cluster-management-google) -- 演讲
- [Borg论文读后感](http://mp.weixin.qq.com/s?__biz=MjM5MzYzMzkyMQ==&mid=204283418&idx=1&sn=658fcdff9eafddfd1542cdb77f81828f#rd)
- [Google发布论文，披露大规模集群管理工具Borg的细节](http://mp.weixin.qq.com/s?__biz=MjM5MDE0Mjc4MA==&mid=205863827&idx=2&sn=650c55fc981f187ad2a34a7906811ac1#rd)
- [google集群操作系统borg](http://pipul.org/2015/05/large-scale-cluster-management-at-google-with-borg/)

### 百度: Matrix
- [百度李闻：类谷歌集群管理系统Borg的百度Matrix](http://news.csdn.net/article_preview.html?preview=1&reload=1&arcid=2822017)

### Common
- [数据中心成本与利用率现状分析](http://www.ccf.org.cn/resources/1190201776262/2015/05/12/8.pdf)

### Others
- [Borg WIKI](http://en.wikipedia.org/wiki/Borg_%28Star_Trek%29)
- [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)
- [Marathon](https://github.com/mesosphere/marathon)
- [DockerOne](http://dockerone.com/)
