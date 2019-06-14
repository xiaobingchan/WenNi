#!/usr/bin/env bash

https://www.shiyanlou.com/courses/237/labs/1042/document/#3.1%20%E5%AE%89%E8%A3%85%20MySql%20%E6%95%B0%E6%8D%AE%E5%BA%93%EF%BC%88%E5%AE%9E%E9%AA%8C%E7%8E%AF%E5%A2%83%E4%B8%AD%E5%B7%B2%E7%BB%8F%E5%AE%89%E8%A3%85%E6%97%A0%E9%9C%80%E5%86%8D%E6%AC%A1%E5%AE%89%E8%A3%85%EF%BC%89

# 创建 hive 用户，若已经存在则无需再创建
mysql> create user 'hive' identified by 'hive';
# 赋予权限
mysql> grant all on *.* TO 'hive'@'%' identified by 'hive' with grant option;
mysql> grant all on *.* TO 'hive'@'localhost' identified by 'hive' with grant option;
# 刷新 MySQL 的系统权限相关表，否则会出现拒绝访问，还有一种方法是重新启动 mysql 服务器，来使新设置生效。
mysql> flush privileges;

mysql -uhive -phive -h hadoop
mysql> create database hive; # 若存在则无需再创建

wget https://mirrors.cnnic.cn/apache/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz
tar -xzvf apache-hive-1.2.2-bin.tar.gz -C /usr/local/
mv /usr/local/apache-hive-1.2.2-bin /usr/local/hive
cp mysql-connector-java-5.1.22-bin.jar /usr/local/hive/lib

cat >> /etc/profile <<EOF
export HIVE_HOME=/usr/local/hive
export PATH=\$PATH:\$HIVE_HOME/bin
export CLASSPATH=\$CLASSPATH:\$HIVE_HOME/bin
EOF
source /etc/profile # 刷新环境变量