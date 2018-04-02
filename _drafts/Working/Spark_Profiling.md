# JVM Profiling原理
[常用 Java Profiling 工具的分析与比较](http://www.ibm.com/developerworks/cn/java/j-lo-profiling/)

### 收集程序运行时信息的方法
##### 事件方法
对于 Java，可以采用 JVMTI（JVM Tools Interface）API 来捕捉诸如方法调用、类载入、类卸载、进入 / 离开线程等事件，然后基于这些事件进行程序行为的分析。

##### 统计抽样方法（sampling）
该方法每隔一段时间调用系统中断，然后收集当前的调用栈（call stack）信息，记录调用栈中出现的函数及这些函数的调用结构，基于这些信息得到函数的调用关系图及每个函数的 CPU 使用信息。由于调用栈的信息是每隔一段时间来获取的，因此不是非常精确的，但由于该方法对目标程序的干涉比较少，目标程序的运行速度几乎不受影响。

##### 植入附加指令方法（BCI）
该方法在目标程序中插入指令代码，这些指令代码将记录 profiling 所需的信息，包括运行时间、计数器的值等，从而给出一个较为精确的内存使用情况、函数调用关系及函数的 CPU 使用信息。该方法对程序执行速度会有一定的影响，因此给出的程序执行时间有可能不准确。但是该方法在统计程序的运行轨迹方面有一定的优势。


###Profiler工具功能简介
##### 遥测（Telemetry）
遥测是一种用来查看应用程序运行行为的最简单的方法。通常会有多个视图（View）分别实时地显示 CPU 使用情况、内存使用情况、线程状态以及其他一些有用的信息，以便用户能很快地发现问题的关键所在。

- CPU Telemetry 视图一般用于显示整个应用程序的 CPU 使用情况，有些工具还能显示应用程序中每个线程的 CPU 使用情况。
- Memory Telemetry 视图一般用于显示堆内存和非堆内存的分配和使用情况。
- Garbage Collection Telemetry 视图显示了 JVM 中垃圾收集器的详细信息。
- Threads Telemetry 视图一般用于显示当前运行线程的个数、守护进程的个数等信息。
- Classes Telemetry 视图一般用于显示已经载入和还没有载入的类的数量。

##### 快照（snapshot）
应用程序启动后，profiler 工具开始收集各种执行数据，其中一些数据直接显示在遥测视图中，而另外大部分数据被保存在内部，直到用户要求获取快照，基于这些保存的数据的统计信息才被显示出来。快照包含了应用程序在一段时间内的执行信息，通常有两种类型的快照：CPU 快照和内存快照。

- CPU 快照主要包含了应用程序中函数的调用关系及运行时间，这些信息通常可以在 CPU 快照视图中进行查看。
- 内存快照则主要包含了内存的分配和使用情况、载入的所有类、存在的对象信息及对象间的引用关系。这些信息通常可以在内存快照视图中进行查看。

##### CPU Profiling
CPU Profiling 的主要目的是统计函数的调用情况及执行时间，或者更简单的情况就是统计应用程序的 CPU 使用情况。通常有两种方式来显示 CPU Profiling 结果：CPU 遥测和 CPU 快照。

##### 内存 Profiling
内存 Profiling 的主要目的是通过统计内存使用情况检测可能存在的内存泄露问题及确定优化内存使用的方向。通常有两种方式来显示内存 Profiling 结果：内存遥测和内存快照

##### 线程 Profiling
线程 Profiling 主要用于在多线程应用程序中确定内存的问题所在。 一般包括三个方面的信息：

- 某个线程的状态变化情况
- 死锁情况
- 某个线程在线程生命期内状态的分布情况

##### Profiling 的启动设置
类似于 eclipse 中 Run 和 Debug 的启动设置，进行 Profiling 之前也需要进行启动设置，包括：profiling 的模式 (CPU profiling 或内存 profiling)，信息获取类型（遥测 , 抽样统计或者 BCI ) 等等。

##### Profiler Preference 设置
主要用于 Profiler 过滤器（选择需要关注的包、类）、取样间隔时间的设置等。


# JVM Profiling工具
[9 个帮助你进行Java性能调优的工具](http://www.open-open.com/news/view/1ec20f6)
[推荐 7 个超棒的监控工具](http://www.codeceo.com/article/7-monitor-tools.html)

### Plumbr
- [官网](https://portal.plumbr.eu/#/)

### VisualVM
- [官网](http://visualvm.java.net/)
- [使用 VisualVM 进行性能分析及调优](http://www.ibm.com/developerworks/cn/java/j-lo-visualvm/)
- [visualvm监控jvm及远程jvm监控方法](http://www.blogjava.net/titanaly/archive/2012/03/20/372318.html)

![](http:/../../../images.blogjava.net/blogjava_net/titanaly/概况.png)

![](http://www.ibm.com/developerworks/cn/java/j-lo-visualvm/nEO_IMG_image026.jpg)


### YourKit
增加 -agentpath:<full agent library path> VM 选项到java 命令行启动参数

- [官网](https://www.yourkit.com/overview/)
- [yourkit性能监控工具，远程监控](http://zhwj184.iteye.com/blog/764575)

<img src="http://dl2.iteye.com/upload/attachment/0031/1361/e47a5383-6b24-38e3-8555-1e21224598fc.jpg" width="1000px" />

![](https://www.yourkit.com/docs/java/help/cpu_call_tree_all_threads.png)

![](https://www.yourkit.com/docs/java/help/cpu_hot_spots.png)


### Profiler4j
java -javaagent:c:\profiler4j-1.0-beta2\agent.jar com.foo.Main

- [官网](http://profiler4j.sourceforge.net/)

![](http://profiler4j.sourceforge.net/callgraph.png)

![](http://profiler4j.sourceforge.net/calltree.png)

### JProfiler

- [官网](https://www.ej-technologies.com/products/jprofiler/overview.html)
- [JProfiler入门笔记](http://blog.csdn.net/chendc201/article/details/22897999)

![](http:/../../../images.cnitblog.com/blog/467292/201307/12091547-b4d908300a3c4275abcecf49cfc6181b.png)


### Perf
- [Perf](http://www.brendangregg.com/perf.html)

# Distributed JVM Profiling

### 论文
- [JaViz: A client/server Java profiling tool](http://ieeexplore.ieee.org/xpl/login.jsp?tp=&arnumber=5387066&url=http%3A%2F%2Fieeexplore.ieee.org%2Fxpls%2Fabs_all.jsp%3Farnumber%3D5387066) 收费论文，无法下载


### statsd-jvm-profiler (A JVM Profiler for Hadoop)
- [Github](https://github.com/etsy/statsd-jvm-profiler)
- [Introducing statsd-jvm-profiler: A JVM Profiler for Hadoop](https://codeascraft.com/2015/01/14/introducing-statsd-jvm-profiler-a-jvm-profiler-for-hadoop/)

<img src="https://codeascraft.com/wp-content/uploads/2015/01/ds-6vthx31g08wko.png" width="1000px" />

### Time Series Database

| TSDB       | Storage    | Scalability           | Storage Format    | Query    |
|------------|------------|-----------------------|-------------------|----------|
| OpenSDB    | HBase      | Base On HBase         | Aggregrate Series | API      |
| Influxdb   | Local File | Cluster + Replication | Rows of Events    | SQL Like |


##### OpenTSDB (The Scalable Time Series Database)
- [官网](http://opentsdb.net/)
- [OpenTSDB监控系统的研究和介绍](http://www.ttlsa.com/opentsdb/opentsdb-research-and-monitoring-system-introduced/)

优点：可以利用现有的Hadoop，HBase作为分布式存储，TSD Server之间没有依赖关系，可以很方便的增加TSD Server

缺点：不支持SQL Like的Query Language，内置的API比较弱

![](http://opentsdb.net/img/tsdb-architecture.png)


##### Influxdb (Distributed Time Series database)
- [官网](http://influxdb.com/)

优点：适合存储Schema不定的数据

缺点：存储Schema固定的数据会占用比较多的空间，因为不会对相同Schema的数据进行Aggregrate；需要自己维护集群



### StatsD
- [Github](https://github.com/etsy/statsd)
- [Understanding StatsD and Graphite](https://blog.pkhamre.com/understanding-statsd-and-graphite/)
- [How To Configure StatsD to Collect Arbitrary Stats for Graphite](https://www.digitalocean.com/community/tutorials/how-to-configure-statsd-to-collect-arbitrary-stats-for-graphite-on-ubuntu-14-04)
- [Measure Anything, Measure Everything](https://codeascraft.com/2011/02/15/measure-anything-measure-everything/)


### Graphite
- [HTTP API](https://github.com/brutasse/graphite-api/blob/master/docs/api.rst)


### Flame Graph
- [Github](https://github.com/brendangregg/FlameGraph)
- [Flame Graphs](http://www.brendangregg.com/flamegraphs.html)
- [Node.js in Flames](http://techblog.netflix.com/2014/11/nodejs-in-flames.html)


### Java调优
- [Java SE 6 HotSpot[tm] Virtual Machine Garbage Collection Tuning](http://www.oracle.com/technetwork/java/javase/gc-tuning-6-140523.html)
- [Everything I Ever Learned about JVM Performance Tuning](http://www.infoq.com/presentations/JVM-Performance-Tuning-twitter)
- [java profiling heapster](https://github.com/mariusae/heapster) - Production heap profiling for the JVM
- [java profiling jvmgcprof](https://github.com/twitter/jvmgcprof) - A simple utility for profile allocation and garbage collection activity in the JVM


### Spark Profiling
- spark.python.profile
- spark.python.profile.dump
- [Profiling Spark Applications Using YourKit](https://cwiki.apache.org/confluence/display/SPARK/Profiling+Spark+Applications+Using+YourKit)


### Picutres
![](https://databricks.com/wp-content/uploads/2015/05/Screen-Shot-2015-05-26-at-3.20.31-PM.png)

![](https://databricks.com/wp-content/uploads/2015/05/Screen-Shot-2015-05-26-at-3.21.36-PM.png)

![](https://databricks.com/wp-content/uploads/2015/05/Screen-Shot-2015-05-26-at-3.22.13-PM.png)

![](https://databricks.com/wp-content/uploads/2015/05/Screen-Shot-2015-05-26-at-3.22.45-PM.png)
