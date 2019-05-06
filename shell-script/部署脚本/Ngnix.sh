#!/usr/bin/env bash

wget http://nginx.org/download/nginx-1.16.0.tar.gz

yum install -y patch openssl pcre pcre-devel make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils

tar zxvf /data/soft/nginx-1.16.0.tar.gz -C /data/ioszdhyw/soft
cd  /data/ioszdhyw/soft/`echo /data/soft/nginx-1.16.0.tar.gz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tar" '{print $NR}'`
./configure  --prefix=/data/ioszdhyw/soft/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module --without-http_rewrite_module
make && make install

filepath=/data/ioszdhyw/soft/nginx/conf/nginx.conf
pid="sed -i '/"deny"/d' ${filepath}"
eval $pid
line_number_raw=`grep -rn 'logs/host.access.log' "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
line_number=${line_number_raw%:*}
user_content='location /nginx_status'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
line_number=`echo ${line_number}| awk '{print int($0)}'`
let line_number=line_number+1
user_content='{'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
let line_number=line_number+1
user_content='stub_status on;'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
let line_number=line_number+1
user_content='access_log off;'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
let line_number=line_number+1
user_content='allow 127.0.0.1;'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
let line_number=line_number+1
user_content='deny all;'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`
let line_number=line_number+1
user_content='}'
add_text=`sed -i "$line_number"i"$user_content" "/data/ioszdhyw/soft/nginx/conf/nginx.conf"`

# /etc/sysconfig/iptables
# -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
# service iptables restart

# firewall-cmd --zone=public --add-port=4200/tcp --permanent
# firewall-cmd --reload

/data/ioszdhyw/bin/nginx


