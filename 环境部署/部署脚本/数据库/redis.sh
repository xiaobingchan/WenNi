#!/usr/bin/env bash
wget http://download.redis.io/releases/redis-5.0.5.tar.gz
tar -xzvf redis-5.0.5.tar.gz -C /usr/local/
yum install -y gcc
cd /usr/local/redis-5.0.5/deps
make hiredis jemalloc linenoise lua
cd /usr/local/redis-5.0.5
make MALLOC=libc
firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --reload
/usr/local/redis/src/redis-server /usr/local/redis/redis.conf




