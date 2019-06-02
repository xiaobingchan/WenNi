#!/usr/bin/env bash

# https://www.cnblogs.com/qiuhao/p/6192950.html

# wget http://archive.apache.org/dist/httpd/httpd-2.4.9.tar.gz
cd /usr/local/

wget http://archive.apache.org/dist/apr/apr-1.6.5.tar.gz
wget http://archive.apache.org/dist/apr/apr-util-1.6.1.tar.gz
wget http://jaist.dl.sourceforge.net/project/pcre/pcre/8.43/pcre-8.43.tar.gz
wget http://ftp.cuhk.edu.hk/pub/packages/apache.org/httpd/httpd-2.4.39.tar.gz

yum -y install libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel mysql pcre-devel curl-devel  libxslt-devel libxslt libxslt-devel
yum -y install gcc-c++ gcc

cd /usr/local/
tar -zxvf apr-1.6.5.tar.gz
cd  apr-1.6.5
./configure --prefix=/usr/local/apr/
make && make install

cd /usr/local/
tar -zxvf apr-util-1.6.1.tar.gz
cd apr-util-1.6.1
 ./configure --prefix=/usr/local/apr-util/ --with-apr=/usr/local/apr/
make && make install

cd /usr/local/
tar -zxvf pcre-8.43.tar.gz
cd pcre-8.43
  ./configure --prefix=/usr/local/pcre/
make && make install

cd /usr/local/
tar -xzvf httpd-2.4.39.tar.gz
cd  httpd-2.4.39/
 ./configure --prefix=/usr/local/apache/ --with-apr=/usr/local/apr/ --with-apr-util=/usr/local/apr-util/ --with-pcre=/usr/local/pcre/
make && make install

cd /usr/local/apache/bin/
./apachectl start
cp /usr/local/apache/bin/apachectl  /etc/rc.d/init.d/
mv /etc/rc.d/init.d/apachectl /etc/rc.d/init.d/httpd

cd /usr/local/
wget http://ftp.ntu.edu.tw/pub/php/distributions/php-7.3.5.tar.gz
tar -xzvf php-7.3.5.tar.gz
cd php-7.3.5/
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs  --with-curl  --with-freetype-dir  --with-gd  --with-gettext  --with-iconv-dir  --with-kerberos  --with-libdir=lib64  --with-libxml-dir  --with-mysqli  --with-openssl  --with-pcre-regex  --with-pdo-mysql  --with-pdo-sqlite  --with-pear  --with-png-dir  --with-xmlrpc  --with-xsl  --with-zlib  --enable-fpm  --enable-bcmath  --enable-libxml  --enable-inline-optimization  --enable-gd-native-ttf  --enable-mbregex  --enable-mbstring  --enable-opcache  --enable-pcntl  --enable-shmop  --enable-soap  --enable-sockets  --enable-sysvsem  --enable-xml  --enable-zip
make clean
make && make install
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

/usr/local/php/sbin/php-fpm -t
cp /usr/local/php-7.3.5/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
 /etc/init.d/php-fpm start
 wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer
chmod a+x /usr/local/bin/composer
composer -v
composer config -g repo.packagist composer https://packagist.phpcomposer.com

cp /usr/local/php/bin/* /usr/bin/
php -v

vi /usr/local/apache/conf/httpd.conf
############################################
AddType application/x-httpd-php .php
############################################

/etc/rc.d/init.d/httpd restart