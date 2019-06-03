#!/usr/bin/env bash

# https://zhuanlan.zhihu.com/p/34684496
# https://segmentfault.com/a/1190000011683097

cd E:\vagrant\centos7.2

vagrant init samdoran/rhel7 --box-version 1.2.0
vagrant up
vagrant ssh
ssh -p 2222 vagrant@127.0.0.1

git clone https://github.com/holms/vagrant-centos7-box/releases/download/7.1.1503.001/CentOS-7.1.1503-x86_64-netboot.box
vagrant box add centos7.2 E:/vagrant/box/CentOS-7.1.1503-x86_64-netboot.box
vagrant init
# 编辑Vagrantfile
config.vm.box = "centos7.2"
vagrant up
vagrant ssh
ssh -p 2222 vagrant@127.0.0.1