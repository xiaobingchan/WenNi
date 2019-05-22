#!/usr/bin/env bash
mkdir -p /data/soft/nginx-mongodb/
cd /data/soft/nginx-mongodb/

yum -y update
yum -y install wget pcre-devel openssl-devel zlib-devel git gcc gcc-c++

# wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.0.0.tgz
# wget http://nginx.org/download/nginx-1.12.2.tar.gz

# git clone git://github.com/mdirolf/nginx-gridfs.git
# cd nginx-gridfs/
# git submodule init
# git submodule update

pkill -9 nginx
pkill -9 mongo
rm -rf /usr/local/nginx
rm -rf /usr/local/mongodb

tar xvf nginx-gridfs.tar.gz
tar xzvf nginx-1.12.2.tar.gz
cd nginx-1.12.2
./configure --prefix=/usr/local/nginx   --with-openssl=/usr/include/openssl --add-module=/data/soft/nginx-mongodb/nginx-gridfs

##############################################################
vi /data/soft/nginx-mongodb/nginx-1.12.2/objs/Makefile # 去掉"-Werror"
##############################################################
make && make install
cat /proc/cpuinfo
##############################################################
rm -rf /usr/local/nginx/conf/nginx.conf
vi /usr/local/nginx/conf/nginx.conf

worker_processes  4;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name 192.168.240.113;
        location /file/ {
            gridfs FILEDB
            root_collection=fs
            field=filename
            type=string;
            mongo 192.168.240.113:20000;
            access_log  logs/gridfs.access.log;
            error_log   logs/gridfs.error.log;
       }
   }
    server {
        listen       80;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

}

##############################################################
/usr/local/nginx/sbin/nginx -t
/usr/local/nginx/sbin/nginx
ps aux | grep nginx
##############################################################
cat /etc/redhat-release
cd /data/soft/nginx-mongodb
# wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.0.0.tgz
tar xzvf mongodb-linux-x86_64-rhel70-4.0.0.tgz -C /usr/local/
cd /usr/local
mv mongodb-linux-x86_64-rhel70-4.0.0 mongodb
cd mongodb
mkdir data
mkdir log
mkdir etc
chown -R 777 data log etc
cd etc
touch /usr/local/mongodb/log/mongo.log
chown -R 777 /usr/local/mongodb/log/mongo.log
##############################################################
vi mongodb.conf
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/log/mongo.log
logappend=true
quiet=true
port=20000
fork=true
bind_ip=0.0.0.0
##############################################################
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/etc/mongodb.conf

cd /data/soft/nginx-mongodb/
/usr/local/mongodb/bin/mongofiles -h 118.89.23.220 -d FILEDB --port 20000 put 2.jpg
/usr/local/mongodb/bin/mongofiles -h 118.89.23.220 -d FILEDB --port 20000 get 2.jpg
/usr/local/mongodb/bin/mongofiles -h 118.89.23.220 -d FILEDB --port 20000 list
###############################################################
http://118.89.23.220/file/2.jpg
