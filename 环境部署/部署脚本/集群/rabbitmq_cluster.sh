#!/usr/bin/env bash

#  参考文章：https://segmentfault.com/a/1190000010702020

wget http://distfiles.macports.org/erlang/otp_src_21.1.tar.gz
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.15/rabbitmq-server-3.7.15-1.el7.noarch.rpm
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel perl unixODBC-devel xz  wxBase wxGTK SDL wxGTK-gl lksctp-tools  libxslt xmlto

cat >> /etc/hosts  << EOF
192.168.56.1    node1
192.168.56.2    node2
192.168.56.3    node3
EOF

tar xf otp_src_21.1.tar.gz
cd otp_src_21.1
./configure --prefix=/usr/local/erlang --without-javac
make
make install
cat >> /etc/profile <<EOF
export ERLANG_HOME=/usr/local/erlang
export PATH=\$PATH:\$ERLANG_HOME/bin
EOF
source /etc/profile
cd ..
rpm -ivh --nodeps --force rabbitmq-server-3.7.15-1.el7.noarch.rpm

# 主机
firewall-cmd --zone=public --add-port=4369/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public --add-port=25672/tcp --permanent
firewall-cmd --reload
rabbitmq-server  -detached
chmod 777 /var/lib/rabbitmq/.erlang.cookie
scp /var/lib/rabbitmq/.erlang.cookie node2:/var/lib/rabbitmq/
scp /var/lib/rabbitmq/.erlang.cookie node3:/var/lib/rabbitmq/
rabbitmqctl stop
rabbitmq-server -detached

# 节点
firewall-cmd --zone=public --add-port=4369/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public --add-port=25672/tcp --permanent
firewall-cmd --reload
chmod 600 /var/lib/rabbitmq/.erlang.cookie
chown rabbitmq /var/lib/rabbitmq/.erlang.cookie
chgrp rabbitmq /var/lib/rabbitmq/.erlang.cookie
rabbitmqctl stop
rabbitmq-server -detached
rabbitmqctl stop_app
rabbitmqctl join_cluster rabbit@node1
rabbitmqctl start_app
rabbitmqctl add_user zdhyw zdhyw@Password
rabbitmqctl  set_user_tags zdhyw administrator
rabbitmq-plugins enable rabbitmq_management

# 主机
rabbitmqctl cluster_status