#!/usr/bin/env bash

yum -y install net-tools
yum groupinstall -y "Development tools"
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel
yum install -y python-devel
wget --no-check-certificat  https://pypi.python.org/packages/source/s/setuptools/setuptools-2.0.tar.gz
tar zxf setuptools-2.0.tar.gz
cd setuptools-2.0
python setup.py install
cd  ..
wget https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz --no-check-certificate
tar -xzvf pip-1.3.1.tar.gz
cd pip-1.3.1
python setup.py install
python -m pip install --upgrade pip