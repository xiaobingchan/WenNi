#!/usr/bin/env bash

#教程：https://cloud.tencent.com/developer/article/1005764

wget http://mysql.mirror.kangaroot.net/Downloads/MySQL-Cluster-7.3/mysql-cluster-gpl-7.3.24-linux-glibc2.12-x86_64.tar.gz
yum -y install autoconf
groupadd mysql
useradd mysql -g mysql
tar -zxvf mysql-cluster-gpl-7.3.24-linux-glibc2.12-x86_64.tar.gz -C /usr/local/
cd /usr/local
mv mysql-cluster-gpl-7.3.24-linux-glibc2.12-x86_64/ mysql/
chown -R mysql:mysql mysql
su - mysql
cd /usr/local/mysql
scripts/mysql_install_db --user=mysql --datadir=/usr/local/mysql/data

# 管理节点
mkdir -p /var/lib/mysql-cluster
cd /var/lib/mysql-cluster
rm -rf config.ini
cat > config.ini << EOF
[NDBD DEFAULT]
NoOfReplicas=2
[NDB_MGMD]
#设置管理节点服务器
nodeid=1
HostName=192.168.244.138
DataDir=/var/lib/mysql-cluster
[NDBD]
id=2
HostName=192.168.244.139
DataDir=/usr/local/mysql/data
[NDBD]
id=3
HostName=192.168.244.140
DataDir=/usr/local/mysql/data
[MYSQLD]
id=4
HostName=192.168.244.139
[MYSQLD]
id=5
HostName=192.168.244.140
#必须有空的mysqld节点，不然数据节点断开后启动有报错
[MYSQLD]
id=6
[mysqld]
id=7
EOF
chown -R mysql:mysql /var/lib/mysql-cluster
firewall-cmd --zone=public --add-port=1186/tcp --permanent
firewall-cmd --reload
su - mysql
mkdir -p /usr/local/mysql/mysql-cluster
/usr/local/mysql/bin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini --initial
/usr/local/mysql/bin/ndb_mgm
mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
cat > /etc/my.cnf << EOF
[mysqld]
ndbcluster
ndb-connectstring=192.168.244.138
[mysql_cluster]
ndb-connectstring=192.168.244.138
EOF
firewall-cmd --zone=public --add-port=1186/tcp --permanent
firewall-cmd --reload
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
su - mysql
/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
service mysqld start
/usr/local/mysql/bin/mysqladmin -u root password '12345678'


mkdir -p /var/lib/mysql-cluster
chown -R mysql:mysql /var/lib/mysql
cat > /etc/my.cnf << EOF
[mysqld]
ndbcluster
ndb-connectstring=192.168.244.138
[mysql_cluster]
ndb-connectstring=192.168.244.138
EOF
firewall-cmd --zone=public --add-port=1186/tcp --permanent
firewall-cmd --reload
su - mysql
/usr/local/mysql/bin/ndbd --initial


mkdir -p /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql
cat > /etc/my.cnf << EOF
[mysqld]
ndbcluster
ndb-connectstring=192.168.244.138
[mysql_cluster]
ndb-connectstring=192.168.244.138
EOF
firewall-cmd --zone=public --add-port=1186/tcp --permanent
firewall-cmd --reload
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
su - mysql
/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
service mysqld start
/usr/local/mysql/bin/mysqladmin -u root password '12345678'
