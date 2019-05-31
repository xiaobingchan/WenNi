#!/usr/bin/env bash

运维监控工具Zabbix
开启：systemctl start zabbix-server
停止：systemctl stop zabbix-server
# 账号：Admin , 密码：zabbix
# 浏览器访问：http://192.168.56.1/zabbix/
# 官方文档：https://www.zabbix.com/documentation/4.0/zh/manual

yum -y update
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/SELINUX=TARGETED/SELINUX=disabled/g" /etc/selinux/config
systemctl stop firewalld.service && systemctl disable firewalld.service

yum -y install httpd
systemctl start httpd.service
systemctl stop httpd.service
systemctl restart httpd.service
systemctl enable httpd.service
systemctl disable httpd.service

yum -y install php
yum -y install php-mysqlnd php-gd libjpeg* php-snmp php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-bcmath php-mhash php-common php-ctype php-xml php-xmlreader php-xmlwriter php-session php-mbstring php-gettext php-ldap php-mysqli --skip-broken
yum -y install wget telnet net-tools python-paramiko gcc gcc-c++ dejavu-sans-fonts python-setuptools python-devel sendmail mailx net-snmp net-snmp-devel net-snmp-utils freetype-devel libpng-devel perl unbound libtasn1-devel p11-kit-devel OpenIPMI unixODBC

rpm -ivh http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-java-gateway zabbix-web
cd /usr/share/doc/zabbix-server-mysql-3.4.15/
vim /etc/zabbix/zabbix_server.conf

gunzip /usr/share/doc/zabbix-server-mysql-3.4.15/create.sql.gz
mysql -u root -p
create database zabbix character set utf8; #创建数据库
create user zabbix@'%' identified by 'Qingdao@2017'; #创建用户和密码
grant all privileges on zabbix.* to zabbix@'%'; #赋权
flush privileges;
use zabbix;
source /usr/share/doc/zabbix-server-mysql-3.4.15/create.sql
exit;

############
DBPassword=Qingdao@2017
DBSocket=/tmp/mysql.sock
CacheSize=512M
（CacheSize在371行）
HistoryCacheSize=128M
（HistoryCacheSize在397行）
HistoryIndexCacheSize=128M
（HistoryIndexCacheSize在405行）
TrendCacheSize=128M
（TrendCacheSize在414行）
ValueCacheSize=256M
（ValueCacheSize在425行）
Timeout=30
（Timeout在432）
StartVMwareCollectors=2
（StartVMwareCollectors在272行）
VMwareCacheSize=256M
（VMwareCacheSize 在298行）
VMwareTimeout=300
（VMwareTimeout在306行）
############
vim /etc/httpd/conf.d/zabbix.conf
############
php_value max_execution_time 600
php_value memory_limit 256M
php_value post_max_size 32M
php_value upload_max_filesize 32M
php_value max_input_time 600
php_value always_populate_raw_post_data -1
php_value date.timezone Asia/Shanghai
############

systemctl restart httpd && systemctl restart zabbix-server

############
