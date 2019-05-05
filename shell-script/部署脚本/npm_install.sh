#!/usr/bin/env bash
yum -y install gcc gcc-c++ kernel-devel

cd /data/soft
wget https://nodejs.org/dist/v9.9.0/node-v9.9.0.tar.gz
tar -xzvf node-v9.9.0.tar.gz -C /data/soft/
cd /data/soft/node-v9.9.0
./configure
make && make install

