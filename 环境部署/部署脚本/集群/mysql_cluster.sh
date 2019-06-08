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
[ndb_mgmd default]
# Directory for MGM node log files
DataDir=/var/lib/mysql-cluster
[ndb_mgmd]
#Management Node db1
HostName=10.0.2.15
[ndbd default]
NoOfReplicas=1      # Number of replicas
DataMemory=256M     # Memory allocate for data storage
IndexMemory=128M    # Memory allocate for index storage
#Directory for Data Node
DataDir=/var/lib/mysql-cluster
[ndbd]
#Data Node db2
HostName=10.0.2.18
[mysqld]
#SQL Node db3
HostName=10.0.2.19
EOF
chown -R mysql:mysql /var/lib/mysql-cluster
firewall-cmd --zone=public --add-port=1186/tcp --permanent
firewall-cmd --reload
su - mysql
mkdir -p /usr/local/mysql/mysql-cluster
/usr/local/mysql/bin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini --initial
/usr/local/mysql/bin/ndb_mgm


mkdir -p /var/lib/mysql-cluster
chown -R mysql:mysql /var/lib/mysql
cat > /etc/my.cnf << EOF
[mysqld]
ndbcluster
ndb-connectstring=192.168.56.1
[mysql_cluster]
ndb-connectstring=192.168.56.1
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
ndb-connectstring=192.168.56.1
[mysql_cluster]
ndb-connectstring=192.168.56.1
EOF
firewall-cmd --zone=public --add-port=1186/tcp --permanent
firewall-cmd --reload
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
su - mysql
/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
service mysqld start
/usr/local/mysql/bin/mysqladmin -u root password '12345678'
