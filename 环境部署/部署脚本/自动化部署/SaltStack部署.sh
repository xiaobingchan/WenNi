#!/usr/bin/env bash

# https://blog.codecp.org/2016/10/19/Centos7%E5%AE%89%E8%A3%85Saltstack/

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i  's/$releasever/7/g' /etc/yum.repos.d/CentOS-Base.repo
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache

yum install salt-master
yum install salt-minion
yum install salt-ssh
yum install salt-syndic
yum install salt-cloud

setenforce 0
vi /etc/sysconfig/selinux
SELINUX=disabled
firewall-cmd --permanent --zone=public --add-port=4505/tcp
firewall-cmd --permanent --zone=public --add-port=4506/tcp
firewall-cmd --reload

# 主机端
vi /etc/salt/master
# 绑定master通讯IP
interface: 192.168.1.125
# 设置自动认证，主要用于大批量的客户端认证
auto_accept: True
# 配置文件根目录
file_roots:
  base:
    - /srv/salt
systemctl enable salt-master
systemctl start salt-master

# 受控端
vi /etc/salt/minion
# 指定mater主机IP
master: 192.168.1.125
# 修改被控端主机识别ID，推荐系统主机名
id: 192.168.1.126
systemctl enable salt-minion
systemctl start salt-minion


salt "*" test.ping
salt "192.168.1.126" cmd.run "free -m"

