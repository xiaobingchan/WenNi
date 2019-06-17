#!/usr/bin/env bash

# 搭建教程：https://www.liangzl.com/get-article-detail-39154.html

JDK (1.8 or later versions)
MySQL(version 5.6及以上)
Hadoop (2.6.0 or later)
Hive (version 2.x)
Spark (version 2.2.1)
Livy（livy-0.5.0-incubating）:         http://loupipalien.com/2018/04/how-to-deploy-livy/
ElasticSearch (5.0 or later versions):

################################################################################################
rpm -ivh jdk-8u152-linux-x64.rpm  # 安装jdk到目录/usr/local
pid="sed -i '/export JAVA_HOME/d' /etc/profile"
eval $pid # 删除已经存在的JAVA_HOME环境变量
pid="sed -i '/export CLASSPATH/d' /etc/profile"
eval $pid # 删除已经存在的CLASSPATH环境变量
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile # 刷新环境变量
################################################################################################
yum -y install wget gcc gcc-c++ ncurses ncurses-devel cmake numactl.x86_64
#wget http://mysql.mirror.kangaroot.net/Downloads/MySQL-5.7/mysql-5.7.24-el7-x86_64.tar.gz
tar -zxvf mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz -C /usr/local
mv /usr/local/mysql-5.7.24-linux-glibc2.12-x86_64/ /usr/local/mysql
cd /usr/local/mysql/
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
cat >/etc/my.cnf <<EOF
[client]
port=3306
socket=/tmp/mysql.sock
[mysqld]
port=3306
socket=/tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
basedir=/usr/local/mysql
datadir=/var/lib/mysql
EOF
mkdir -p /var/lib/mysql
chmod -R 777 /var/lib/mysql
mkdir /var/log/mariadb
chown -R 777 /var/log/mariadb/
touch /var/log/mariadb/mariadb.log
mkdir /var/run/mariadb
chown -R 777 /var/run/mariadb/
touch /var/run/mariadb/mariadb.pid
mv /var/lib/mysql/ /var/lib/mysql_bak/
cat  >> /etc/profile << EOF
export PATH=\$PATH:/usr/local/mysql/bin:/usr/local/mysql/lib
EOF
source /etc/profile
useradd mysql
cd /usr/local/mysql/bin/
./mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
/etc/init.d/mysql start
################################################################################################
#wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5.tar.gz
tar -zxvf  hadoop-2.6.5.tar.gz -C /usr/local
cd /usr/local
mv hadoop-2.6.5/ hadoop/
cat >> /etc/profile <<EOF
export HADOOP_HOME=/usr/local/hadoop
export CLASSPATH=\$(\$HADOOP_HOME/bin/hadoop classpath):\$CLASSPATH
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile # 刷新环境变量

cat >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh<<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
EOF

vi /usr/local/hadoop/etc/hadoop/core-site.xml <<EOF
<configuration>
        <property>
             <name>hadoop.tmp.dir</name>
             <value>file:/usr/local/hadoop/tmp</value>
             <description>Abase for other temporary directories.</description>
        </property>
        <property>
             <name>fs.defaultFS</name>
             <value>hdfs://localhost:9000</value>
        </property>
</configuration>
EOF

vi /usr/local/hadoop/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
        <property>
             <name>dfs.replication</name>
             <value>1</value>
        </property>
        <property>
             <name>dfs.namenode.name.dir</name>
             <value>file:/usr/local/hadoop/tmp/dfs/name</value>
        </property>
        <property>
             <name>dfs.datanode.data.dir</name>
             <value>file:/usr/local/hadoop/tmp/dfs/data</value>
        </property>
</configuration>
EOF
cat >> /usr/local/hadoop/etc/hadoop/log4j.properties <<EOF
log4j.logger.org.apache.hadoop.util.NativeCodeLoader=ERROR
EOF
systemctl stop firewalld
/usr/local/hadoop/bin/hdfs namenode -format

################################################################################################
mysql -u root -p
set password=password('123456');

tar -xzvf apache-hive-1.2.2-bin.tar.gz -C /usr/local/
mv /usr/local/apache-hive-1.2.2-bin/ /usr/local/hive/
cp mysql-connector-java-5.1.22-bin.jar /usr/local/hive/lib/
cat >> /etc/profile <<EOF
export HIVE_HOME=/usr/local/hive
export HIVE_CONF_DIR=$HIVE_HOME/conf
export PATH=\$PATH:\$HIVE_HOME/bin
export PATH CLASSPATH HIVE_HOME HIVE_CONF_DIR
EOF
source /etc/profile # 刷新环境变量
cp /usr/local/hive/conf/hive-default.xml.template /usr/local/hive/conf/hive-site.xml
vi /usr/local/hive/conf/hive-site.xml
##############################################################
<name>hive.metastore.warehouse.dir</name>
<value>/user/hive/warehouse</value>
<name>hive.exec.scratchdir</name>
<value>/tmp/hive</value>
##############################################################
hadoop fs -mkdir -p  /user/hive/warehouse
hadoop fs -chmod -R 777 /user/hive/warehouse
hadoop fs -mkdir -p /tmp/hive/
hadoop fs -chmod -R 777 /tmp/hive

cd /usr/local/hive
mkdir tmp
chmod -R 777 tmp/
vi /usr/local/hive/conf/hive-site.xml
##############################################################
<property>
    <name>system:java.io.tmpdir</name>
    <value>/usr/local/hive/tmp</value>
  </property>
  <property>
    <name>system:user.name</name>
    <value>root</value>
  </property>

<name>hive.downloaded.resources.dir</name>
<value>/usr/local/hive/tmp/${hive.session.id}_resources</value>
<name>hive.server2.logging.operation.log.location</name>
<value>/usr/local/hive/tmp/root/operation_logs</value>
   <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <name>javax.jdo.option.ConnectionURL</name>
 <value>jdbc:mysql://127.0.0.1:3306/hive?createDatabaseIfNotExist=true</value>
<name>javax.jdo.option.ConnectionUserName</name>
<value>root</value>
<name>javax.jdo.option.ConnectionPassword</name><value>123456</value>
##############################################################
cp /root/mysql-connector-java-5.1.22-bin.jar /usr/local/hive/lib/
cp /usr/local/hive/conf/hive-env.sh.template /usr/local/hive/conf/hive-env.sh
cat >> /usr/local/hive/conf/hive-env.sh <<EOF
export HADOOP_HOME=/usr/local/hadoop
export HIVE_CONF_DIR=/usr/local/hive/conf
export HIVE_AUX_JARS_PATH=/usr/local/hive/lib
EOF

rm -rf /usr/local/hadoop/share/hadoop/yarn/lib/jline-0.9.94.jar
cp /usr/local/hive/lib/jline-2.12.jar /usr/local/hadoop/share/hadoop/yarn/lib/
sh /usr/local/hadoop/sbin/start-all.sh
curl -I http://localhost:50070 # http://192.168.56.1:50070
jps

schematool -initSchema -dbType mysql
hive
################################################################################################
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
################################################################################################
wget http://mirror.bit.edu.cn/apache/incubator/livy/0.6.0-incubating/apache-livy-0.6.0-incubating-bin.zip
unzip apache-livy-0.6.0-incubating-bin.zip
mkdir -p /root/apache-livy-0.6.0-incubating-bin/logs
chmod -R 777 /root/apache-livy-0.6.0-incubating-bin/logs
/root/apache-livy-0.6.0-incubating-bin/bin/livy-server
