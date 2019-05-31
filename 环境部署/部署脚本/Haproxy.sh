#!/usr/bin/env bash

wget https://src.fedoraproject.org/repo/pkgs/haproxy/haproxy-1.8.19.tar.gz/sha512/f62b0a18f19295986d26c5c60b6b1ad55850a175bed67a359282cc37a4c630a0c2be51d608226b4316f2e69c3008c20a1cb91ce10f86311219355973a050e65b/haproxy-1.8.19.tar.gz
tar zxvf haproxy-1.8.19.tar.gz
cd haproxy-1.8.19/
make TARGET=linux310 ARCH=x86_64 PREFIX=/usr/local/haproxy
make install PREFIX=/usr/local/haproxy
cd /usr/local/haproxy/
mkdir conf
cd conf/
cat  >> haproxy.cfg << EOF
global
        log 127.0.0.1   local0
        maxconn 1000
        daemon

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        retries 3
        timeout connect 5000
        timeout client  50000
        timeout server 50000

listen admin_stats
        bind 0.0.0.0:1080
        mode http
        option httplog
        maxconn 10
        stats refresh 30s
        stats uri /stats
        stats realm XingCloud\ Haproxy
        stats auth admin:admin
        stats auth  Frank:Frank
        stats hide-version
        stats admin if TRUE
EOF
/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/conf/haproxy.cfg
# http://118.89.23.220:1080/stats