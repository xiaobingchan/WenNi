#!/usr/bin/env bash
# https://blog.csdn.net/weixin_41515615/article/details/80873328
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.1.tar.gz
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
yum -y install httpd httpd-devel gcc glibc glibc-common gd gd-devel perl-devel perl-CPAN fcgi perl-FCGI perl-FCGI-ProcManager

useradd nagios -s /sbin/nologin
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd www

yum -y install gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel xinetd unzip

tar xvf nagios-4.3.1.tar.gz
cd nagios-4.3.1/
 ./configure --with-command-group=nagcmd
make all
make install-init
make install-commandmode
make install-config
make install    
cp -R contrib/eventhandlers/ /usr/local/nagios/libexec/
chown -R nagios:nagios /usr/local/nagios/libexec/eventhandlers
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
make install-webconf

useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -G nagcmd apache

wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.3.1.tar.gz
tar xvf nagios-4.3.1.tar.gz
cd nagios-4.3.1
./configure --with-command-group=nagcmd
make all
make install
make install-commandmode
make install-init
make install-config
make install-webconf
htpasswd -c /usr/local/nagios/etc/htpasswd.users nagios

cd ..
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
tar xvf nagios-plugins-2.2.1.tar.gz
cd nagios-plugins-2.2.1
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
make install

vi /etc/httpd/conf/httpd.conf
Listen 8080
User www
Group www
DirectoryIndex index.php index.html
AddType application/x-gzip .gz .tgz
AddHandler application/x-httpd-php .php
LoadModule foo_module modules/mod_foo.so
LoadModule php7_module modules/libphp7.so


cd ..
wget http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
tar xvf nrpe-2.15.tar.gz
cd nrpe-2.15/mkdir /usr/local/nagios/etc/servers
./configure --enable-command-args --with-nagios-user=nagios --with-nagios-group=nagios --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/x86_64-linux-gnu
make all
make install
make install-xinetd
make install-daemon-config

vi /etc/xinetd.d/nrpe
############################
only_from       = 127.0.0.1 118.89.23.220
############################
service xinetd restart

vi /usr/local/nagios/etc/nagios.cfg
############################
cfg_dir=/usr/local/nagios/etc/servers
############################

cat /usr/local/nagios/etc/objects/commands.cfg <<EOF
define command{
        command_name check_nrpe
        command_line $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
EOF

htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

systemctl daemon-reload
systemctl start nagios.service
systemctl restart httpd.service

vi /usr/local/nagios/etc/nagios.cfg
cfg_dir=/usr/local/nagios/etc/servers

mkdir -p /usr/local/nagios/etc/servers