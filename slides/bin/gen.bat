#!/bin/bash

FWDIR="$(cd "`dirname "$0"`"/..; pwd)"
cd $FWDIR

landslide SparkMemoryManagement/Index.md -i -d gen/SparkMemoryManagement.html
landslide HadoopSecurity/Index.md -i -d gen/HadoopSecurity.html
landslide Spark2.0andSparkAPIHistory/Index.md -i -d gen/Spark2.0andSparkAPIHistory.html
