#!/usr/bin/env bash

rpm -ivh jdk-8u152-linux-x64.rpm
pid="sed -i '/export JAVA_HOME/d' /etc/profile"
eval $pid
pid="sed -i '/export CLASSPATH/d' /etc/profile"
eval $pid
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile

cd /root
wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz
tar -zxvf zookeeper-3.4.14.tar.gz
cd zookeeper-3.4.14/src/c/
./configure --prefix=/usr/local/zookeeper
make && make install
cat > /root/zookeeper-3.4.14/conf/zoo.cfg << EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/root/zookeeper-3.4.14/data
dataLogDir=/root/zookeeper-3.4.14/logs
clientPort=2181
EOF
/root/zookeeper-3.4.14/bin/zkServer.sh start
/root/zookeeper-3.4.14/bin/zkCli.sh -server 127.0.0.1:2181


