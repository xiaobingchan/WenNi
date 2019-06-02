#!/usr/bin/env bash

#https://www.linuxidc.com/Linux/2017-02/140932.htm


yum install -y wget
wget http://yum.puppetlabs.com/el/7/products/x86_64/puppetlabs-release-7-10.noarch.rpm
yum install -y puppetlabs-release-7-10.noarch.rpm
yum update -y

# Master端
yum install -y ruby facter puppet-server
chkconfig  puppet on
chkconfig  puppetmaster on
firewall-cmd --permanent --zone=public --add-port=8140/tcp
firewall-cmd --reload
cat >> /etc/hosts << EOF
192.168.56.1 server.your.domain
192.168.56.2 client-node.your.domain
EOF
cat >> /etc/puppet/puppet.conf << EOF
[master]
certname=server.your.domain
EOF
cat > /etc/puppet/autosign.conf << EOF
server.your.domain
client-node.your.domain
EOF
service puppet start
service puppetmaster start

# Agent端
yum install -y ruby facter puppet
chkconfig  puppet on
cat >> /etc/hosts << EOF
192.168.56.1 server.your.domain
192.168.56.2 client-node.your.domain
EOF
cat >> /etc/puppet/puppet.conf << EOF
[agent]
certname = client-node.your.domain
server = server.your.domain
report = true
EOF
firewall-cmd --permanent --zone=public --add-port=8140/tcp
firewall-cmd --reload
service puppet start
service puppetmaster start
puppet agent --test

# Master端
puppet cert list --all
cat  > /etc/puppet/manifests/site.pp << EOF
node default {
file {
"/tmp/helloworld.txt": content => "hello, world";
}
}
EOF

# Agent端
puppet agent --test --server=server.your.domain
cat /tmp/helloworld.txt