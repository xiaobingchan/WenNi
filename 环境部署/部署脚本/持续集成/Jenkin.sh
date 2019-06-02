#!/usr/bin/env bash

# https://www.cnblogs.com/loveyouyou616/p/8714544.html
# 教程：https://www.cnblogs.com/xiewenming/p/7490828.html

rpm -ivh jdk-8u152-linux-x64.rpm  # 安装jdk到目录/usr/local
pid="sed -i '/export JAVA_HOME/d' /etc/profile"
eval $pid # 删除已经存在的JAVA_HOME环境变量
pid="sed -i '/export CLASSPATH/d' /etc/profile"
eval $pid # 删除已经存在的CLASSPATH环境变量
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile # 刷新环境变量

yum -y install wget
wget http://pkg.jenkins-ci.org/redhat-stable/jenkins-2.164.3-1.1.noarch.rpm
rpm -ivh jenkins-2.164.3-1.1.noarch.rpm
service jenkins start
cat /var/lib/jenkins/secrets/initialAdminPassword  #  15d6a447915a49138c64f0cfa24be545
firewall-cmd --permanent --zone=public --add-port=8080/tcp
firewall-cmd --reload

