#!/bin/bash
# date         2019-03-04
# author       luyanjie
# company      NanWangZongBu
# version          1.0.1
#file:S0017-mysql-install.sh
#examples:sh :S0017-mysql-install.sh /root/boost_1_59_0.tar.gz /root/mysql-5.7.22.tar.gz /usr/local 123456

yum -y install wget gcc gcc-c++ ncurses ncurses-devel cmake numactl.x86_64
wget http://mysql.mirror.kangaroot.net/Downloads/MySQL-5.7/mysql-5.7.24-el7-x86_64.tar.gz
tar -zxvf mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
mv /usr/local/mysql-5.7.24-linux-glibc2.12-x86_64/ /usr/local/mysql
cd /usr/local/mysql/
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
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
basedir=/usr/local/mysql
datadir=/var/lib/mysql
bind-address=0.0.0.0
EOF
rm -rf /usr/local/mysql/data
mkdir -p /usr/local/mysql/data
chown mysql:mysql /usr/local/mysql/data
rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chown mysql:mysql /var/lib/mysql
rm -rf /var/log/mariadb
mkdir -p /var/log/mariadb
chown mysql:mysql /var/log/mariadb/
rm -rf /var/log/mariadb/mariadb.log
touch /var/log/mariadb/mariadb.log
rm -rf /var/run/mariadb
mkdir -p /var/run/mariadb
chown mysql:mysql /var/run/mariadb/
rm -rf /var/run/mariadb/mariadb.pid
touch /var/run/mariadb/mariadb.pid
mv /var/lib/mysql/ /var/lib/mysql_bak/
cat  >> /etc/profile << EOF
export PATH=\$PATH:/usr/local/mysql/bin:/usr/local/mysql/lib
EOF
source /etc/profile
useradd mysql
pkill -9 mysql
cd /usr/local/mysql/
scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql --ldata=/var/lib/mysql
/etc/init.d/mysql start

mysql -u root -p
set password for root@localhost=password('123456');
GRANT ALL PRIVILEGES ON *.* TO 'root'@'*' IDENTIFIED BY '123456' with grant option;
flush privileges;