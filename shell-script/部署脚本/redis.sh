#!/usr/bin/env bash

mkdir -p /data/soft

tar -xzvf redis-4.0.10.tar.gz -C /data/soft/
yum install -y gcc
cd /data/soft/redis-4.0.10/deps
make hiredis jemalloc linenoise lua
cd /data/soft/redis-4.0.10
make MALLOC=libc

mv /data/soft/redis-4.0.10 /data/soft/redis/

#增加配置
cluster-enabled yes
cluster-config-file nodes-6379.conf
cluster-node-timeout 15000
pidfile /var/run/redis_6379.pid

firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --reload

/data/soft/redis/src/redis-server /data/soft/redis/redis.conf


