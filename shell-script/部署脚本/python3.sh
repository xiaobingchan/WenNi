#!/usr/bin/env bash

yum groupinstall -y "Development tools"  # 安装工具开发包
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel  # 安装python3依赖库

wget https://www.python.org/ftp/python/3.5.4/Python-3.5.4.tgz  # 下载 python3.5.4源码包
tar zxvf Python-3.5.4.tgz # 解压源码包

cd `echo Python-3.5.4.tgz |awk 'BEGIN{FS="/"}''{print $NF}'| awk -F".tgz" '{print $NR}'`  # 进入源码包目录
./configure  --prefix=/root/python3_5  # 指定编译安装位置
make && make install  # 编译安装

ln -s /root/python3_5/bin/pip3 /usr/bin/  # 创建python3软链接
ln -s /root/python3_5/bin/pip3 /usr/bin/  # 创建pip3软链接