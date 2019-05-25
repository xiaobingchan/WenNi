#!/usr/bin/env bash

yum install -y gcc libxml2-devel openssl openssl-devel bzip2 bzip2-devel curl-devel libmcrypt libmcrypt-devel mcrypt mhash readline-devel systemtap-sdt-devel

yum remove libzip
wget https://nih.at/libzip/libzip-1.2.0.tar.gz
tar -zxvf libzip-1.2.0.tar.gz
cd libzip-1.2.0
./configure
make && make install

cp /usr/bin/python /usr/bin/python2
cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h
wget http://ftp.ntu.edu.tw/pub/php/distributions/php-7.3.5.tar.gz
./configure --prefix=/home/luyanjie/php --with-config-file-path=/etc --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-opcache --enable-fpm --with-fpm-user=www --with-fpm-group=www --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gettext --enable-mbstring --with-iconv --with-mcrypt --with-mhash --with-openssl --enable-bcmath --enable-soap --with-libxml-dir --enable-pcntl --enable-shmop --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-sockets --with-curl --with-zlib --enable-zip --enable-dtrace --enable-maintainer-zts --with-bz2 --with-readline --without-sqlite3 --without-pdo-sqlite --with-pear --with-openssl
make clean
make && make install
cp php.ini-production /home/luyanjie/php/etc/php.ini
cp /home/luyanjie/php/etc/php-fpm.conf.default /home/luyanjie/php/etc/php-fpm.conf
cp /home/luyanjie/php/etc/php-fpm.d/www.conf.default /home/luyanjie/php/etc/php-fpm.d/www.conf

/usr/local/php/sbin/php-fpm -t
cp /data/soft/php-7.3.5/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
/etc/init.d/php-fpm start

cp /usr/local/php/bin/* /usr/bin/

vi /usr/local/php/etc/php.ini
extension=openssl

curl -sS https://getcomposer.org/installer | php
mv composer.phar  /usr/local/bin/composer
mv composer.phar  /usr/bin/composer