#!/usr/bin/env bash
wget https://downloads.lightbend.com/scala/2.10.7/scala-2.10.7.tgz

tar -xzvf scala-2.10.7.tgz -C /usr/local/
mv /usr/local/scala-2.10.7/ /usr/local/scala/

cat >> /etc/profile <<EOF
export SCALA_HOME=/usr/local/scala/
export PATH=\$PATH:\$SCALA_HOME/bin
EOF
source /etc/profile # 刷新环境变量

***********************************************************************************************

wget https://mirrors.cnnic.cn/apache/spark/spark-2.3.3/spark-2.3.3-bin-hadoop2.6.tgz
tar -xzvf spark-2.3.3-bin-hadoop2.6.tgz -C /usr/local/
mv /usr/local/spark-2.3.3-bin-hadoop2.6/ /usr/local/spark

cat >> /etc/profile <<EOF
export SPARK_HOME=/usr/local/spark
export PATH=\$PATH:\$SPARK_HOME/bin
EOF
source /etc/profile # 刷新环境变量
cp -r /usr/local/spark/conf/spark-env.sh.template /usr/local/spark/conf/spark-env.sh
cat >>  /usr/local/spark/conf/spark-env.sh <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152/
export SPARK_MASTER_IP=master
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=1g
export SPARK_WORKER_INSTANCES=2
export SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.retainedApplications=3 -Dspark.history.fs.logDirectory=hdfs://master:9000/historyServerForSpark/logs"
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=FILESYSTEM -Dspark.deploy.recoveryDirectory=/usr/local/spark/recovery"
EOF
cp -r /usr/local/spark/conf/spark-defaults.conf.template /usr/local/spark/conf/spark-defaults.conf
cat >>  /usr/local/spark/conf/spark-defaults.conf <<EOF
spark.master  spark://localhost:7077
spark.network.timeout 500
EOF

/usr/local/spark/sbin/start-all.sh
spark


Windows下载安装：
