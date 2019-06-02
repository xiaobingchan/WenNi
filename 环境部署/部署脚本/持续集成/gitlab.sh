#!/usr/bin/env bash

# https://www.cnblogs.com/wenwei-blog/p/5861450.html
# https://packages.gitlab.com/gitlab/gitlab-ce

yum -y install policycoreutils openssh-server openssh-clients postfix
systemctl enable postfix && systemctl start postfix

firewall-cmd --permanent --zone=public --add-port=9091/tcp
firewall-cmd --reload

wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-11.9.9-ce.0.el7.x86_64.rpm
yum -y install policycoreutils-python
rpm -i gitlab-ce-11.9.9-ce.0.el7.x86_64.rpm

vi  /etc/gitlab/gitlab.rb
external_url 'http://127.0.0.1:9091'  # 配置访问地址
nginx['listen_port'] = 9091  # 配置端口

gitlab-ctl reconfigure
gitlab-ctl restart

free -m
curl http://127.0.0.1:9091