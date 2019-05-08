#!/usr/bin/env bash

firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --reload

#增加配置
bind 0.0.0.0
cluster-enabled yes
cluster-config-file nodes-6379.conf
cluster-node-timeout 15000
pidfile /var/run/redis_6379.pid

yum -y install ruby ruby-devel rubygems rpm-build

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
find / -name rvm -print
source /usr/local/rvm/scripts/rvm
rvm list known
rvm install 2.4.5
rvm use 2.4.5 --default

gem install redis

/data/soft/redis/src/redis-trib.rb create --replicas 127.0.0.1:6379 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005