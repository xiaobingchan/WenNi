#!/usr/bin/env bash

vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
ONBOOT YES
service network restart

# 关闭防火墙
cat  >> /etc/sysconfig/selinux  << EOF
SELINUX=disabled
EOF

# centos7防火墙增加22端口
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --reload

# centos6防火墙增加22端口
vi /etc/sysconfig/iptables
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
service iptables restart

# ssh 连接速度优化：
vi /etc/ssh/sshd_config
UseDNS no #不使用dns解析
GSSAPIAuthentication no #连接慢的解决配置
service sshd restart

# 基础软件
yum install -y net-tools wget unzip

# yum源换阿里源
mkdir -p /etc/yum.repos.d/defaul
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/default
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

# yum换上扩展源
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
sed -i  's/$releasever/7/g' /etc/yum.repos.d/CentOS-Base.repo
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache

# 内核优化
cat >>/etc/sysctl.conf<<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
EOF
sysctl -p

# 精简开机：
chkconfig --list|egrep -v "sysstat|crond|sshd|network|rsyslog"|awk '{print "chkconfig "$1,"off"}'|bash

# 时间同步：
yum install -y ntpdate
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
yes | cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
ntpdate us.pool.ntp.org
crontab -l >/tmp/crontab.bak
echo "10 * * * * /usr/sbin/ntpdate us.pool.ntp.org | logger -t NTP" >> /tmp/crontab.bak
crontab /tmp/crontab.bak
date


