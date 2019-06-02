#!/usr/bin/env bash

wget --no-check-certificat  https://pypi.python.org/packages/source/s/setuptools/setuptools-2.0.tar.gz
tar zxf setuptools-2.0.tar.gz
cd setuptools-2.0
python setup.py install

cd ../

wget https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz --no-check-certificate
tar -xzvf pip-1.3.1.tar.gz
cd pip-1.3.1
python setup.py install

