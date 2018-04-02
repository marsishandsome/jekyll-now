# 用InfluxDB+Grafana搭建实时监控系统

```
# python influxdb
tar zxvf pip-7.1.0.tar.gz
cd pip-7.1.0
python setup.py install
pip install influxdb

# influxdb
mkdir influxdb
cd influxdb
yum install -y influxdb-0.9.2-1.x86_64.rpm
chmod a+x start-influxdb.sh
ln -s /opt/influxdb/versions/0.9.2/influx /usr/local/bin/influx
ln -s /opt/influxdb/versions/0.9.2/influxd /usr/local/bin/influxd
./start-influxdb.sh

influx
drop database online
create database online
ALTER RETENTION POLICY default ON test2 DURATION 3d
CREATE RETENTION POLICY profiling ON test2 DURATION 3d REPLICATION 1 DEFAULT
SHOW RETENTION POLICIES on test2

# grafana
tar zxvf grafana-2.1.1.linux-x64.tar.gz
cd grafana-2.1.1
chmod a+x start-grafana.sh
./start-grafana.sh
```
