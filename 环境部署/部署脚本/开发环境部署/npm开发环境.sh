#!/usr/bin/env bash
yum -y install gcc gcc-c++ kernel-devel # 安装node.js依赖

cd /data/soft
wget https://nodejs.org/dist/v9.9.0/node-v9.9.0.tar.gz #下载安装包
tar -xzvf node-v9.9.0.tar.gz -C /data/soft/
cd /data/soft/node-v9.9.0
./configure
make && make install

