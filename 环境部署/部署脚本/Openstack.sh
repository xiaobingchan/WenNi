#!/usr/bin/env bash

#  https://blog.csdn.net/helloholiday/article/details/79695375

systemctl stop firewalld
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
yum -y install git;
useradd -s /bin/bash -d /opt/stack -m stack

mkdir -p  /root/.pip
cat > /root/.pip/pip.conf <<EOF
[global]
trusted-host =  pypi.douban.com
index-url = http://pypi.douban.com/simple
EOF
mkdir -p  /home/stack/.pip
cat > /home/stack/.pip/pip.conf <<EOF
[global]
trusted-host =  pypi.douban.com
index-url = http://pypi.douban.com/simple
EOF

echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
su - stack

git clone https://git.openstack.org/openstack-dev/devstack;
cd /opt/stack/devstack

cat > /opt/stack/devstack/local.conf << EOF
[[local|localrc]]
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
EOF

./stack.sh



yum -y update
systemctl stop NetworkManager.servicesystemctl
systemctl disable NetworkManager.service
systemctl restart network
setenforce 0
systemctl stop firewalld

yum -y update device-mapper
yum install -y http://rdo.fedorapeople.org/rdo-release.rpm
yum install -y openstack-packstack
packstack --allinone