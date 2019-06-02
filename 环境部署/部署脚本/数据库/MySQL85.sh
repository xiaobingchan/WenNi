#!/bin/bash
# date         2019-03-04
# author       luyanjie
# company      NanWangZongBu
# version          1.0.1
#file:S0017-mysql-install.sh
#examples:sh :S0017-mysql-install.sh /root/boost_1_59_0.tar.gz /root/mysql-5.7.22.tar.gz /usr/local 123456

mkdir -p /data/soft/
cd  /data/soft/
yum -y install wget gcc gcc-c++ ncurses ncurses-devel cmake numactl.x86_64
wget http://mysql.mirror.kangaroot.net/Downloads/MySQL-5.7/mysql-5.7.24-el7-x86_64.tar.gz
tar -zxvf /data/soft/mysql-5.7.24-el7-x86_64.tar.gz -C /data/soft
mv /data/soft/mysql-5.7.24-el7-x86_64/ /data/soft/mysql
cd /data/soft/mysql/
cp /data/soft/mysql/support-files/mysql.server /etc/init.d/mysql
cat >/etc/my.cnf <<EOF
[client]
port=3306
socket=/tmp/mysql.sock
[mysqld]
port=3306
socket=/tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
basedir=/data/soft/mysql
datadir=/var/lib/mysql
EOF
mkdir -p /var/lib/mysql
chmod -R 777 /var/lib/mysql
mkdir /var/log/mariadb
chown -R 777 /var/log/mariadb/
touch /var/log/mariadb/mariadb.log
mkdir /var/run/mariadb
chown -R 777 /var/run/mariadb/
touch /var/run/mariadb/mariadb.pid
mv /var/lib/mysql/ /var/lib/mysql_bak/
cat  >> /etc/profile << EOF
export PATH=\$PATH:/data/soft/mysql/bin:/data/soft/mysql/lib
EOF
source /etc/profile
useradd mysql
pkill -9 mysql
cd /data/soft/mysql/bin/
./mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
/etc/init.d/mysql start

