#!/usr/bin/env bash

# https://www.centos.bz/2018/08/%e8%87%aa%e5%8a%a8%e5%8c%96%e8%bf%90%e7%bb%b4%e5%b7%a5%e5%85%b7-saltstack%e5%ae%89%e8%a3%85%e9%83%a8%e7%bd%b2%e5%8f%8a%e7%ae%80%e5%8d%95%e6%a1%88%e4%be%8b/

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

#################################################################
systemctl stop firewalld.service
setenforce 0
cat >> /etc/hostname << EOF
192.168.244.138 master.saltstack.com
192.168.244.139 web01.saltstack.com
EOF

vi /etc/salt/master

interface: 192.168.244.138
auto_accept: True
file_roots:
    base:
         - /srv/salt
pillar_roots:
     base:
        - /srv/pillar
pillar_opts: True
nodegroups:
    group1: 'web01.saltstack.com'

cat /etc/salt/master | grep -v ^$ | grep -v ^#
mkdir /srv/salt
mkdir /srv/pillar
systemctl start salt-master.service
netstat -natp | egrep '4505|4506'

###########################################################################
systemctl stop firewalld.service
setenforce 0
cat >> /etc/hostname << EOF
192.168.244.138 master.saltstack.com
192.168.244.139 web01.saltstack.com
EOF

vi /etc/salt/minion
master: 192.168.244.138
id: web01.saltstack.com

cat /etc/salt/minion | grep -v ^$ | grep -v ^#

systemctl start salt-minion.service
###########################################################################


salt "*" test.ping
salt "192.168.1.126" cmd.run "free -m"

