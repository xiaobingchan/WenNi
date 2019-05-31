#!/usr/bin/env bash
pkill -9 nginx
rm -rf /usr/local/nginx
pkill -9 mongo
pkill -9 mongod
rm -rf /usr/local/mongodb_file/

cd /data/soft/nginx-mongodb
wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-2.6.9.tgz
tar xzvf mongodb-linux-x86_64-rhel70-2.6.9.tgz -C /usr/local/
cd /usr/local
mv mongodb-linux-x86_64-rhel70-2.6.9 mongodb_file
cd mongodb_file
mkdir data
mkdir log
mkdir etc
chown -R 777 data log etc
touch /usr/local/mongodb_file/log/mongo.log
chown -R 777 /usr/local/mongodb_file/log/mongo.log

cd etc
vi mongodb.conf   # 修改配置文件如下：
######################################################################################
dbpath=/usr/local/mongodb_file/data
logpath=/usr/local/mongodb_file/log/mongo.log
logappend=true
journal=true
quiet=true
fork=true
port=20000
auth=true
bind_ip = 0.0.0.0
######################################################################################
/usr/local/mongodb_file/bin/mongod -f /usr/local/mongodb_file/etc/mongodb.conf
/usr/local/mongodb_file/bin/mongo --port=20000
use admin
db.createUser({user: "dx",pwd: "dx",roles: [ { role: "userAdminAnyDatabase", db: "admin" }]})
db.auth('dx','dx')
use FILEDB
db.createUser({user: "dx",pwd: "dx",roles: [ { role: "readWrite", db: "FILEDB" }]})
exit

# 上传文件到mongodb的FILEDE库
/usr/local/mongodb_file/bin/mongofiles put --host 10.92.190.135 -u dx -p dx --port 20000 --db FILEDB --local /data/soft/nginx-mongodb/1.jpg --type jpg
cd /data/soft/nginx_mongodb
/usr/local/mongodb_file/bin/mongofiles -h  10.92.190.135 -u dx -p dx -d FILEDB --port 20000 put 1.jpg

######################################################################################
pkill -9 nginx
rm -rf /usr/local/nginx
cd /data/soft/nginx-mongodb
#  下载安装包，链接：https://pan.baidu.com/s/1cup-KtIYtaAEqCaZp2dTbA ,提取码：23hf
tar -xzvf nginx-gridfs.tar.gz
cd /data/soft/nginx-mongodb
wget http://nginx.org/download/nginx-1.14.2.tar.gz
tar -xzvf nginx-1.14.2.tar.gz
cd nginx-1.14.2/
./configure --prefix=/usr/local/nginx   --with-openssl=/usr/include/openssl --add-module=/data/soft/nginx_mongodb/nginx-gridfs
vi objs/Makefile  # 去掉-Werror
make -j8 && make install -j8

rm -rf /usr/local/nginx/conf/nginx.conf
vi /usr/local/nginx/conf/nginx.conf     # 修改配置文件如下：
######################################################################################
user  root;
worker_processes  4;

error_log  logs/error.log;

pid        logs/nginx.pid;

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
    server {
        listen       800;
        server_name  192.168.240.113;
        location /file/ {
            gridfs FILEDB
            root_collection=fs
            field=filename
            type=string
            user=foo
            pass=bar;
                mongo 192.168.240.113:20000;
                access_log  logs/gridfs.access.log;
                error_log   logs/gridfs.error.log;
       }
}
}
######################################################################################

/usr/local/nginx/sbin/nginx   # 启动Nginx

# 访问 http://10.92.190.135:800/file/2.jpg