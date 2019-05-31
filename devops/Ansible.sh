#!/usr/bin/env bash

# Ansible搭建博客：https://www.cnblogs.com/gzxbkk/p/7515634.html

yum install ansible

ssh-keygen -t rsa -P ''
# 把密钥写入所有机器
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

vim /etc/ansible/ansible.cfg
remote_port = 22
private_key_file = /root/.ssh/id_rsa

vim /etc/ansible/hosts
# 配置执行机器
[storm_cluster]
192.168.56.1
192.168.56.2

ansible storm_cluster -m command -a 'uptime'
ansible storm_cluster -m ping
ansible storm_cluster -m command -a "ls –al /tmp/resolv.conf"
ansible storm_cluster -m copy -a "src=/etc/ansible/ansible.cfg dest=/tmp/ansible.cfg owner=root group=root mode=0644"

