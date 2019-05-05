#!/usr/bin/env bash
git clone git://github.com/mdirolf/nginx-gridfs.git
cd nginx-gridfs/
git submodule init
git submodule update

cd /data/soft/
wget http://nginx.org/download/nginx-1.16.0.tar.gz
yum install -y patch openssl pcre pcre-devel make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils
tar -xzvf /data/soft/nginx-1.16.0.tar.gz -C /data/ioszdhyw/soft
cd  /data/ioszdhyw/soft/`echo /data/soft/nginx-1.16.0.tar.gz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tar" '{print $NR}'`
./configure --prefix=/data/soft/nginx --with-http_stub_status_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module --without-http_rewrite_module --add-module=/data/soft/nginx-gridfs
make && make install
/data/soft/nginx/sbin/nginx

server {
        listen       80;
        server_name localhost;
        location /file/ {
            gridfs FILEDB
            root_collection=fs
            field=filename
            type=string;
            mongo localhost:20000;
            access_log  logs/gridfs.access.log;
            error_log   logs/gridfs.error.log;
       }
   }

#/data/soft/mongodb/bin/mongofiles --port=20000 -d FILEDB put /data/soft/1.jpg -t jpg