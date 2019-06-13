#!/usr/bin/env bash

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

wget https://www-eu.apache.org/dist/nifi/1.9.2/nifi-1.9.2-bin.tar.gz

# https://blog.csdn.net/rico_zhou/article/details/81284097
# https://blog.csdn.net/sinat_34233802/article/details/68942176

tar -xzvf nifi-1.9.2-bin.tar.gz
cd nifi-1.9.2/bin
./nifi.sh run


Windows下载地址：https://www.apache.org/dyn/closer.lua?path=/nifi/1.9.2/nifi-1.9.2-bin.zip
Linux下载地址：  https://www.apache.org/dyn/closer.lua?path=/nifi/1.9.2/nifi-1.9.2-bin.tar.gz

