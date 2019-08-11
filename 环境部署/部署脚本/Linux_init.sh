#!/usr/bin/env bash
# Linux初始化系统优化：https://blog.51cto.com/13667208/2108973

vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
ONBOOT YES
service network restart

# 关闭防火墙
cat  >> /etc/sysconfig/selinux  << EOF
SELINUX=disabled
EOF

# 防火墙增加端口
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

vi /etc/sysconfig/iptables
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
service iptables restart

# 创建备份目录
mkdir -p /etc/yum.repos.d/default
mv /etc/yum.repos.d/repo /etc/yum.repos.d/default
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/default

# yum源换阿里源
mkdir -p /etc/yum.repos.d/{default,back}
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/default
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# 基础软件
yum install -y wget unzip lrzsz nmap tree dos2unix nc bc

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
echo '#time sync by oldboy at 2018-04-26' >> /var/spool/cron/root
echo '/5 /usr/sbin/ntpdate ntp1.aliyun.com >/dev/null 2>&1' >> /var/spool/cron/root

# ssh 连接速度优化：
vi /etc/ssh/sshd_config
UseDNS no #不使用dns解析
GSSAPIAuthentication no #连接慢的解决配置
/etc/init.d/sshd restart
#service sshd restart

