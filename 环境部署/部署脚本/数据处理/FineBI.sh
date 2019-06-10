#!/usr/bin/env bash

#  激活码：c6af294c-4c1d24912-b5e5-2043c73d6329
yum -y install wget gcc gcc-c++ ncurses ncurses-devel cmake numactl.x86_64 git
wget http://mysql.mirror.kangaroot.net/Downloads/MySQL-5.7/mysql-5.7.24-el7-x86_64.tar.gz
tar -zxvf mysql-5.7.24-el7-x86_64.tar.gz -C /usr/local
mv /usr/local/mysql-5.7.24-el7-x86_64/ /usr/local/mysql
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
default_authentication_plugin=mysql_native_password
bind-address=0.0.0.0
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
export PATH=\$PATH:/usr/local/mysql/bin:/usr/local/mysql/lib
EOF
source /etc/profile
useradd mysql
cd /usr/local/mysql/bin/
./mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
/etc/init.d/mysql start
mysql -u root -p
###############################################################################
CREATE DATABASE `finebi` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
create user 'luyanjie'@'localhost' identified by '123456';
grant  all privileges  on *.* to  'luyanjie'@'localhost' with grant option;
flush privileges;
###############################################################################

yum -y install wget
wget http://fine-build.oss-cn-shanghai.aliyuncs.com/finebi/5.1/public/exe/spider/linux_unix_FineBI5_1-CN.sh
chmod -R 777 linux_unix_FineBI5_1-CN.sh
sh linux_unix_FineBI5_1-CN.sh
firewall-cmd --zone=public --add-port=37799/tcp --permanent
firewall-cmd --reload
systemctl stop firewalld
cd /usr/local/FineBI5.1/bin
chmod -R 777 finebi
nohup ./finebi &
curl -I http://127.0.0.1:37799/webroot/decision
#  http://192.168.56.1:37799/webroot/decision

