# Spark1.5

## Spark1.5.0

### New experimental user-defined aggregate function (UDAF) interface
- [SPARK-3947](https://issues.apache.org/jira/browse/SPARK-3947)

在SparkSQL中支持用户自定义的聚合函数，先register聚合函数，再在sql语句中调用。
```
class GeometricMean extends UserDefinedAggregateFunction {...}
sqlContext.udf.register("gm", new GeometricMean)
sqlContext.sql("""select gm(filedName) from tableName""");
```

### DataFrame hint for broadcast join
- [SPARK_8300](https://issues.apache.org/jira/browse/SPARK-8300)

根据表的大小是否小于```spark.sql.autoBroadcastJoinThreshold```，Spark会自动判断是否需要使用broadcast join，
新的语法可以让用户直接提示执行器使用broadcast join。
```
left.join(broadcast(right), "joinKey")
```

### Memory and local disk only checkpointing support
- [SPARK-1855](https://issues.apache.org/jira/browse/SPARK-1855)
- [Design Doc](https://issues.apache.org/jira/secure/attachment/12741708/SPARK-7292-design.pdf)

```rdd.checkpoint()```是基于DFS实现的，RDD的数据将会复制3份保持到硬盘，为了提高checkpoint的效率，
Spark提供了```rdd.localCheckpoint()```，Executor会把RDD的数据保持一份到本地磁盘，
提高了checkpoint的效率，但是当某个Executor挂掉时，该份数据将被重算。

### Dynamic allocation in YARN works with preferred locations
- [SPARK-4352](https://issues.apache.org/jira/browse/SPARK-4352)
- [Design Doc](https://issues.apache.org/jira/secure/attachment/12735126/Supportpreferrednodelocationindynamicallocation.pdf)

Spark会记录所有Pending Task的数据依赖，在向Yarn申请资源的时候，会尽量申请靠近数据的执行器。

### Dynamic resource allocation support in Standalone Cluster
- [SPARK-4751](https://issues.apache.org/jira/browse/SPARK-4751)

之前Spark Standalone集群在启动任务前就需要把所需的执行器全部申请好，
现在支持运行起来以后动态增加执行器。

### Faster and more robust dynamic partition insert
- [SPARK-8890](https://issues.apache.org/jira/browse/SPARK-8890)

在使用Insert方式插入数据到HDFS的时候，每个执行器会打开所有需要插入的Partition的文件，
如果需要插入的文件数量很多，会导致执行器OOM。
该Patch只允许每个Executor一次最多打开```spark.sql.sources.maxConcurrentWrites```个文件，
默认值是5。如果大于这个数量，就对所需插入的数据进行外部排序，再依此进行插入。

### Support for YARN cluster mode in R
- [SPARK-6797](https://issues.apache.org/jira/browse/SPARK-6797)

SparkR在Yarn模式下，会把提交机器上```$SPARK_HOME/R/lib/SparkR```包括里面用户下载的RPackages
一起打包成sparkr.zip，并上传到Yarn上，使得Executors可以读取到相应的RPackages。

### Spark Streaming Back Pressure
- [SPARK-7398](https://issues.apache.org/jira/browse/SPARK-7398)
- [PID](http://www.wikiwand.com/en/PID_controller)

因为Spark Streaming没有流量控制，在高峰期的时候每个Batch需要处理的数据会变多，很容易导致OOM问题。
增加了Back Pressure机制以后，Spark会控制每个Batch的数据量，避免OOM。

默认使用以下配置控制流量：
- ```spark.streaming.receiver.maxRate```
- ```spark.streaming.kafka.maxRatePerPartition```

Spark还提供了更加动态的流量控制算法：PID
- ```spark.streaming.backpressure.rateEstimator=pid```

未来除了堆积的策略外，还会加入可配置的策略，例如：采样、丢弃等。

### Better load balancing and scheduling of receivers across cluster
- [SPARK-8882](https://issues.apache.org/jira/browse/SPARK-8882)

Receiver所在的Executor挂掉之后，新增调度算法来调度Receiver。

## Spark1.5.1


## Spark1.5.2


## References
- [Spark1.5.0 Release Notes](http://spark.apache.org/releases/spark-release-1-5-0.html)
- [Spark1.5.1 Release Notes](http://spark.apache.org/releases/spark-release-1-5-1.html)
- [Spark1.5.2 Release Notes](http://spark.apache.org/releases/spark-release-1-5-2.html)
