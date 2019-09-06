#!/usr/bin/env bash
yum install -y libxml2-dev libpng12-dev libfreetype6-dev openssl libcurl3-openssl-dev libjpeg-dev
yum install -y gcc gcc-c++  make zlib zlib-devel pcre pcre-devel  libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers
yum install -y ntp make openssl openssl-devel pcre pcre-devel libpng libpng-devel libjpeg-6b libjpeg-devel-6b freetype freetype-devel gd gd-devel zlib zlib-devel gcc gcc-c++ libXpm libXpm-devel ncurses ncurses-devel libmcrypt libmcrypt-devel libxml2 libxml2-devel imake autoconf automake screen sysstat compat-libstdc++-33 curl curl-devel

groupadd www56
useradd -g www56 www56

tar -zxvf php-5.6.37.tar.gz
cd php-5.6.37
./configure --prefix='/usr/local/php/php5.6.37' --with-config-file-path=/usr/local/php/php5.6.37/etc --with-zlib-dir --with-freetype-dir --enable-mbstring --with-libxml-dir=/usr --enable-soap --enable-calendar --with-curl --with-gd --disable-rpath --enable-inline-optimization --with-bz2 --with-zlib --enable-sockets --enable-sysvsem --enable-sysvshm --enable-pcntl --enable-mbregex --enable-exif --enable-bcmath --with-mhash --enable-zip --with-pcre-regex --with-pdo-mysql --with-mysqli --with-jpeg-dir=/usr --with-png-dir=/usr --with-openssl --with-fpm-user=www56 --with-fpm-group=www56 --with-libdir=/lib/x86_64-linux-gnu/ --enable-ftp --with-gettext --with-xmlrpc --with-xsl --enable-opcache --enable-fpm --with-iconv --with-xpm-dir=/usr --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pear
make && make install
/root/php_new/php-5.6.37/build/shtool install -c ext/phar/phar.phar /usr/local/php/php5.6.37/bin
cp /root/php_new/php-5.6.37/sapi/fpm/init.d.php-fpm /etc/init.d/php56-fpm
chmod +x /etc/init.d/php56-fpm
cp php-fpm.conf.default php-fpm.conf
groupadd -f www56
useradd -g www56 www56
ln -s /usr/local/php/php5.6.37/bin/php* /usr/bin
/etc/init.d/php56-fpm restart

#放置php.ini
#设定session save_path 和权限
#重启php-fpm 和 nginx