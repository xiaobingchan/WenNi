#!/usr/bin/env bash
# 教程：https://github.com/Tencent/bk-cmdb/blob/master/docs/overview/installation.md

cd /root
wget http://download.redis.io/releases/redis-3.2.11.tar.gz
tar -xzvf redis-3.2.11.tar.gz -C /usr/local/
yum install -y gcc
cd /usr/local/redis-3.2.11/deps
make hiredis jemalloc linenoise lua
cd /usr/local/redis-3.2.11
make MALLOC=libc
mv /usr/local/redis-3.2.11 /usr/local/redis/
vi /usr/local/redis/redis.conf
#################################
daemonize yes
requirepass 12345678
#################################
/usr/local/redis/src/redis-server /usr/local/redis/redis.conf

cd /root
wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.2.12-rc0.tgz
tar -xvzf mongodb-linux-x86_64-rhel70-3.2.12-rc0.tgz -C /usr/local/
cd /usr/local
mv mongodb-linux-x86_64-rhel70-3.2.12-rc0/ /usr/local/mongodb/
mkdir -p /usr/local/mongodb/data
mkdir -p /usr/local/mongodb/log
mkdir -p /usr/local/mongodb/etc
touch /usr/local/mongodb/log/mongo.log
cat  >> /etc/profile << EOF
export PATH=$PATH:/usr/local/mongodb/bin
EOF
source /etc/profile
chown -R 777 /usr/local/mongodb/data
chown -R 777 /usr/local/mongodb/log
chown -R 777 /usr/local/mongodb/etc
cat  > /usr/local/mongodb/mongodb.conf << EOF
dbpath=/usr/local/mongodb/data/
logpath=/usr/local/mongodb/log/mongo.log
logappend=true
quiet=true
port=27017
fork=true
bind_ip=127.0.0.1
EOF
/usr/local/mongodb/bin/mongod --config /usr/local/mongodb/mongodb.conf
/usr/local/mongodb/bin/mongo --port=27017
use admin
db.createUser({user: "cc",pwd: "cc",roles: [ { role: "readWrite", db: "admin" } ]})
use cmdb
db.createUser({user: "cc",pwd: "cc",roles: [ { role: "readWrite", db: "cmdb" } ]})

cd /root
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

cd /root
wget https://github.com/Tencent/bk-cmdb/releases/download/release-v3.2.2/cmdb_oc_v3.2.2.tgz
tar -xvzf cmdb_oc_v3.2.2.tgz -C /usr/local
cd /usr/local/cmdb_oc_v3.2.2/
python init.py --discovery 127.0.0.1:2181 --database cmdb --redis_ip 127.0.0.1 --redis_port 6379 --redis_pass 12345678 --mongo_ip 127.0.0.1 --mongo_port 27017 --mongo_user cc --mongo_pass cc --blueking_cmdb_url http://www.yanjushe.com:8083 --listen_port 8083
/usr/local/cmdb_oc_v3.2.2/start.sh
/usr/local/cmdb_oc_v3.2.2/init_db.sh

