---
layout: post
title: Hello SparkR
category: Spark
---
**如果需要运行在Yarn上，Yarn所有机器上需要安装R环境。**

## SparkR的两种使用方式

### 1. SparkR Shell 交互式命令行
SparkR Shell是一个交互式命令行，用户可以输入R代码，进行交互式操作。
SparkR有两种模式：Local模式和Yarn-Client模式。

#### Local模式
Local模式下，任务将会运行在本地机器。
```
$SPARK_HOME/bin/sparkR --master local[*]
```
#### Yarn-Client模式
Yarn-Client模式下，Spark的Driver运行在本地机器，Executor运行在Yarn的节点上。
```
$SPARK_HOME/bin/sparkR --master yarn-client --num-executors 2
```

### 2. Spark Submit 向集群提交任务
通过Spark Submit，用户可以把R的任务提交到集群上运行。
Spark Submit有三种模式：Local模式，Yarn-Client模式以及Yarn-Cluser模式。
其中Local模式和Yarn-Client模式同SparkR Shell，Yarn-Cluser模式中Executor和Driver都运行在Yarn节点。
Local模式和Yarn-Client模式适合调试，Yarn-Cluser模式适合生产环境。
```
$SPARK_HOME/bin/spark-submit --master yarn-cluster --num-executors 2 /path/to/test.R
```

## 如何下载并加载R的External Package?

### 1. 下载依赖的External Packages
用SparkR Shell调用R的函数```install.packages```下载（只需下载一次）需要依赖的External Package，
这些Package会自动下载到$SPARK_HOME/R/lib目录下。
```
$SPARK_HOME/bin/sparkR --master local[*]
install.packages("matlab", repos = "http://mirror.bjtu.edu.cn/cran")
```

### 2. 提交任务到Yarn集群
Spark会自动把```$SPARK_HOME/R/lib```下的R Packages打包成```$SPARK_HOME/R/lib/sparkr.zip```
并上传到相应的Yarn结点。
```
$SPARK_HOME/bin/spark-submit \
--master yarn-cluster \
--num-executors 2 \
/path/to/example.R
```

## SparkR的使用例子

### 使用RDD API
由于SparkR Package中没有export RDD相关的函数，所以只能使用R的语法```:::```来调用RDD API。
```
# Word Count
library(SparkR)
sc <- sparkR.init()
path <- "/tmp/test.txt"

# RDD[String]
rdd <- SparkR:::textFile(sc, path)

# RDD[String]
words <- SparkR:::flatMap(rdd, function(line) {
  strsplit(line, " ")[[1]]
})

# RDD[(String, Int)]
wordCount <- SparkR:::lapply(words, function(word) {
  list(word, 1L)
})

# RDD[(String, Int)]
counts <- SparkR:::reduceByKey(wordCount, "+", 2L)

SparkR:::collect(counts)
```

### 使用R Packages
如果在```SparkR:::lapply```和```SparkR:::lapplyPartition```等函数中使用了R Packages,
这就需要让Spark在执行器上加载相应的R Packages，SparkR提供了```SparkR:::includePackage```函数来完成这个功能。
```
# Use Matrix Package
library(SparkR)
sc <- sparkR.init()

# import Matrix Package on Executors
SparkR:::includePackage(sc, Matrix)

# RDD[Int]
rdd <- SparkR:::parallelize(sc, 1 : 10, 2)

# function: map x to a Matrix
generateSparse <- function(x) {
  sparseMatrix(i=c(1, 2, 3), j=c(1, 2, 3), x=c(1, 2, 3))
}

# RDD[Matrix]
sparseMat <- SparkR:::lapplyPartition(rdd, generateSparse)

SparkR:::collect(sparseMat)
```

### 动态下载R Packages
```install.packages```是R中用来动态安装R Packages的函数，在SparkR中调用这个函数会把对应的R Packages下载到
```$SPARK_HOME/R/lib```目录，如果运行在Yarn模式下，lib目录下所有的R Packages会一起打包成
```$Spark_HOME/R/lib/sparkr.zip```，并上传到相应的Yarn执行器中。
```
# Use Matlab
library(SparkR)

# download matlab Package
install.packages("matlab", repos = "http://mirror.bjtu.edu.cn/cran")

sc <- sparkR.init()
library(matlab)

# import matlab Package on Executors
SparkR:::includePackage(sc, matlab)

# RDD[Int]
rdd <- SparkR:::parallelize(sc, 1 : 10, 2)

# function: map x to ones
generateOnes <- function(x) {
  ones(3)
}

# RDD[ones]
onesRDD <- SparkR:::lapplyPartition(rdd, generateOnes)

SparkR:::collect(onesRDD)
```

## 推荐学习资料
- [Spark Apache官网](http://spark.apache.org/docs/latest/sparkr.html)
- [SparkR API](http://spark.apache.org/docs/latest/api/R/index.html)
- [SparkR 官网（合并到Spark之前)](http://amplab-extras.github.io/SparkR-pkg/)
- [AMP Camp 5: SparkR](https://www.youtube.com/watch?v=OxVIns6zvlk)
- [SparkR: Interactive R programs at Scale - Spark Summit 2014](http://spark-summit.org/2014/talk/sparkr-interactive-r-programs-at-scale-2)
- [SparkR Enabling Interactive Data Science at Scale on Hadoop - Hadoop Summit](https://www.youtube.com/watch?v=Y21t3Taw7i8)
- [SparkR Apache JIRA](https://issues.apache.org/jira/browse/SPARK-5654)
- [SparkR Github Pull Request](https://github.com/apache/spark/pull/5096)
