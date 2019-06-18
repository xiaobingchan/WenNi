#!/usr/bin/env bash

cd  /usr/local/
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz
tar zxvf pcre-8.38.tar.gz -C /usr/local

cd  /usr/local/
wget http://nginx.org/download/nginx-1.16.0.tar.gz
yum install -y patch openssl pcre pcre-devel make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils
tar zxvf nginx-1.16.0.tar.gz -C /usr/local/
cd  /usr/local/`echo /usr/local/nginx-1.16.0.tar.gz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tar" '{print $NR}'`
#./configure  --prefix=/data/ioszdhyw/soft/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module --without-http_rewrite_module --with-pcre=/data/soft/pcre-8.38/

groupadd -f www
useradd -g www www
cd  /usr/local/`echo /usr/local/nginx-1.16.0.tar.gz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tar" '{print $NR}'`
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-pcre=/usr/local/pcre-8.38/ --with-pcre-jit
make && make install

vi /usr/local/nginx/conf/nginx.conf
######################################
location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME /usr/local/nginx/html/$fastcgi_script_name;
            include        fastcgi_params;
        }
######################################

/usr/local/nginx/sbin/nginx

# /etc/sysconfig/iptables
# -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
# service iptables restart

# firewall-cmd --zone=public --add-port=4200/tcp --permanent
# firewall-cmd --reload



