#!/usr/bin/env bash

wget http://download.redis.io/releases/redis-5.0.5.tar.gz
tar -xzvf redis-5.0.5.tar.gz -C /usr/local/
yum install -y gcc
cd /usr/local/redis-5.0.5/deps
make hiredis jemalloc linenoise lua
cd /usr/local/redis-5.0.5
make MALLOC=libc
mv /usr/local/redis-5.0.5 /usr/local/redis/

cd /usr/local/redis
mkdir cluster
cd cluster
mkdir 7000 7001 7002 7003 7004 7005

cp -r /usr/local/redis/redis.conf /usr/local/redis/cluster/7000/
cp -r /usr/local/redis/redis.conf /usr/local/redis/cluster/7001/
cp -r /usr/local/redis/redis.conf /usr/local/redis/cluster/7002/
cp -r /usr/local/redis/redis.conf /usr/local/redis/cluster/7003/
cp -r /usr/local/redis/redis.conf /usr/local/redis/cluster/7004/
cp -r /usr/local/redis/redis.conf /usr/local/redis/cluster/7005/

cat >> /usr/local/redis/cluster/7005/redis.conf  << EOF
####################################
# 端口号
port 7005
# 后台启动
daemonize yes
# 开启集群
cluster-enabled yes
#集群节点配置文件
cluster-config-file nodes-7005.conf
# 集群连接超时时间
cluster-node-timeout 5000
# 进程pid的文件位置
pidfile /var/run/redis-7005.pid
# 开启aof
appendonly yes
# aof文件路径
appendfilename "appendonly-7005.aof"
# rdb文件路径
dbfilename dump-7005.rdb
EOF

/usr/local/redis/src/redis-server /usr/local/redis/cluster/7000/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/cluster/7001/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/cluster/7002/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/cluster/7003/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/cluster/7004/redis.conf
/usr/local/redis/src/redis-server /usr/local/redis/cluster/7005/redis.conf

/usr/local/redis/src/redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 --cluster-replicas 1

/usr/local/redis/src/redis-cli -c -p 7000