#!/usr/bin/env bash
wget http://distfiles.macports.org/erlang/otp_src_21.1.tar.gz
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.15/rabbitmq-server-3.7.15-1.el7.noarch.rpm
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel perl unixODBC-devel xz  wxBase wxGTK SDL wxGTK-gl lksctp-tools  libxslt xmlto

#  参考文章：https://segmentfault.com/a/1190000010702020

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

firewall-cmd --zone=public --add-port=4369/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public --add-port=25672/tcp --permanent
firewall-cmd --reload
rabbitmq-server  -detached