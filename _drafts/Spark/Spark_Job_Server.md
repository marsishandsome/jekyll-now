#Spark Job Server

### Zoomdata
- [Spark Summit](http://spark-summit.org/wp-content/uploads/2015/03/SSE15-14-Zoomdata-Alarcon.pdf)

<img src="../../../images/spark_job_server_arch.png" width="1000px">

![](../../../images/spark_job_server_remoting.png)


### Spark Job Server
- [Spark Summit](http://spark-summit.org/wp-content/uploads/2014/07/Spark-Job-Server-Easy-Spark-Job-Management-Chan-Chu.pdf)
- [Github New](https://github.com/spark-jobserver/spark-jobserver)
- [Github Old](http://github.com/ooyala/spark-jobserver)

![](../../../images/spark_job_server_spark_job_server.png)

1. "Spark as a Service": Simple REST interface for all aspects of job, context management
2. Support for Spark SQL Contexts/jobs and custom job contexts, Works for Spark Streaming as well!
3. Supports sub-second low-latency jobs via long-running job contexts
4. Start and stop job contexts for RDD sharing and low-latency jobs; change resources on restart
5. Kill running jobs via stop context
6. Separate jar uploading step for faster job startup
7. Asynchronous and synchronous job API. Synchronous API is great for low latency jobs!
8. Works with Standalone Spark as well as Mesos and yarn-client
9. Job and jar info is persisted via a pluggable DAO interface
10. Named RDDs to cache and retrieve RDDs by name, improving RDD sharing and reuse among jobs.
11. Jars, job history and config are persisted via a pluggable API
12. Async and sync API, JSON job results

Example

    object WordCountExample extends SparkJob {
    override def validate(sc: SparkContext, config: Config): SparkJobValidation = {
     Try(config.getString(“input.string”))
     .map(x => SparkJobValid)
     .getOrElse(SparkJobInvalid(“No input.string”))
     }
    override def runJob(sc: SparkContext, config: Config): Any = {
     val dd = sc.parallelize(config.getString(“input.string”).split(" ").toSeq)
     dd.map((_, 1)).reduceByKey(_ + _).collect().toMap
     }
    }

### Spark Kernel (IBM)
- [github](https://github.com/ibm-et/spark-kernel)

![](https://raw.githubusercontent.com/wiki/ibm-et/spark-kernel/overview.png)


### HiveThriftServer
- [github](https://github.com/apache/spark/tree/master/sql)


### Spark-Admin 
- provides administrators and developers a GUI to provision and manage Spark clusters easily
- [github](https://github.com/adatao/adatao-admin)


### 二进制兼容问题
- Reading from HDFS
- Spark driver’s hadoop libraries need to match those on the spark cluster
- We made these libraries configurable by:
- Decoupling the spark driver into a separate process
- Allowing administrators to configure what libraries through a UI
- Kicking off a spark driver process with the configured hadoop libraries


