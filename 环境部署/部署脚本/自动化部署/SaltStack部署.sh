#!/usr/bin/env bash

# https://www.cnblogs.com/franknihao/p/7833993.html

# 主机端
yum install -y epel-release
yum install -y salt salt-master
firewall-cmd --permanent --zone=public --add-port=4505/tcp
firewall-cmd --reload
vi /etc/salt/master
*********************************************
#修改master绑定的通信IP
interface: 127.0.0.1
#自动认证模式，避免手动运行salt-key命令
auto_accept: True
*********************************************
systemctl start salt-master

# 客户端
yum install -y epel-release
yum install -y salt salt-minion
firewall-cmd --permanent --zone=public --add-port=4506/tcp
firewall-cmd --reload
vi /etc/salt/minion
*********************************************
#指定master的IP
master: 192.168.56.1
#修改minion的识别ID，通常要保证一个salt网络中的唯一性
id: TestMinion
*********************************************
systemctl start salt-minion
