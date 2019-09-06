#!/usr/bin/env bash

yum install -y gcc libxml2-devel openssl openssl-devel bzip2 bzip2-devel curl-devel libmcrypt libmcrypt-devel mcrypt mhash readline-devel systemtap-sdt-devel libxslt libxslt-devel

yum remove -y libzip
wget https://nih.at/libzip/libzip-1.2.0.tar.gz
tar -zxvf libzip-1.2.0.tar.gz
cd libzip-1.2.0
./configure
make && make install
cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h

echo '/usr/local/lib64
/usr/local/lib
/usr/lib
/usr/lib64'>>/etc/ld.so.conf
ldconfig -v

cd /usr/local/
wget http://ftp.ntu.edu.tw/pub/php/distributions/php-7.3.5.tar.gz
tar -xzvf php-7.3.5.tar.gz
cd php-7.3.5/
./configure --prefix=/usr/local/php --with-config-file-path=/etc --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-opcache --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gettext --enable-mbstring --with-iconv --with-mcrypt --with-mhash --with-openssl --enable-bcmath --enable-soap --with-libxml-dir --enable-pcntl --enable-shmop --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-sockets --with-curl --with-zlib --enable-zip --enable-dtrace --enable-maintainer-zts --with-bz2 --with-readline --without-sqlite3 --without-pdo-sqlite --with-pear
make clean
make && make install
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

groupadd -f www
useradd -g www www

/usr/local/php/sbin/php-fpm -t
cp /usr/local/php-7.3.5/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
/etc/init.d/php-fpm start

cp /usr/local/php/bin/* /usr/bin/
php -v

wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer
chmod a+x /usr/local/bin/composer
composer -v
composer config -g repo.packagist composer https://packagist.phpcomposer.com

cd  /usr/local/
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.gz
tar zxvf pcre-8.38.tar.gz -C /usr/local

cd  /usr/local/
wget http://nginx.org/download/nginx-1.16.0.tar.gz
yum install -y patch openssl pcre pcre-devel make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal nano fonts-chinese gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils
tar zxvf nginx-1.16.0.tar.gz -C /usr/local/
cd  /usr/local/`echo /usr/local/nginx-1.16.0.tar.gz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tar" '{print $NR}'`
#./configure  --prefix=/data/ioszdhyw/soft/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6 --with-http_sub_module --without-http_rewrite_module --with-pcre=/data/soft/pcre-8.38/


cd  /usr/local/`echo /usr/local/nginx-1.16.0.tar.gz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tar" '{print $NR}'`
./configure --user=www --group=www --prefix=/usr/local/nginx_php --with-http_stub_status_module --with-http_ssl_module --with-http_sub_module --with-pcre=/usr/local/pcre-8.38/ --with-pcre-jit
make && make install

vi /usr/local/nginx_php/conf/nginx.conf
######################################
location ~ \.php$ {
            root           html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME /usr/local/nginx_php/html/$fastcgi_script_name;
            include        fastcgi_params;
        }
######################################

/usr/local/nginx_php/sbin/nginx