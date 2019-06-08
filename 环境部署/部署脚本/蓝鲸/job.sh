#!/usr/bin/env bash

# https://github.com/Tencent/bk-sops/blob/master/docs/install/dev_deploy.md
# https://github.com/Tencent/bk-sops/blob/master/docs/install/dev_web.md

cd /root
wget http://download.redis.io/releases/redis-5.0.5.tar.gz
tar -xzvf redis-5.0.5.tar.gz -C /usr/local/
yum install -y gcc
cd /usr/local/redis-5.0.5/deps
make hiredis jemalloc linenoise lua
cd /usr/local/redis-5.0.5
make MALLOC=libc
firewall-cmd --zone=public --add-port=6379/tcp --permanent
firewall-cmd --reload
/usr/local/redis/src/redis-server /usr/local/redis/redis.conf

cd /root
wget http://distfiles.macports.org/erlang/otp_src_21.1.tar.gz
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.15/rabbitmq-server-3.7.15-1.el7.noarch.rpm
yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel perl unixODBC-devel xz  wxBase wxGTK SDL wxGTK-gl lksctp-tools  libxslt xmlto
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

yum -y install wget gcc gcc-c++ ncurses ncurses-devel cmake numactl.x86_64 git
wget http://mysql.mirror.kangaroot.net/Downloads/MySQL-5.7/mysql-5.7.24-el7-x86_64.tar.gz
tar -zxvf mysql-5.7.24-el7-x86_64.tar.gz -C /usr/local
mv /usr/local/mysql-5.7.24-el7-x86_64/ /usr/local/mysql
cd /usr/local/mysql/
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
cat >/etc/my.cnf <<EOF
[client]
port=3306
socket=/tmp/mysql.sock
[mysqld]
port=3306
socket=/tmp/mysql.sock
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
basedir=/usr/local/mysql
datadir=/var/lib/mysql
EOF
mkdir -p /var/lib/mysql
chmod -R 777 /var/lib/mysql
mkdir /var/log/mariadb
chown -R 777 /var/log/mariadb/
touch /var/log/mariadb/mariadb.log
mkdir /var/run/mariadb
chown -R 777 /var/run/mariadb/
touch /var/run/mariadb/mariadb.pid
mv /var/lib/mysql/ /var/lib/mysql_bak/
cat  >> /etc/profile << EOF
export PATH=\$PATH:/usr/local/mysql/bin:/usr/local/mysql/lib
EOF
source /etc/profile
useradd mysql
cd /usr/local/mysql/bin/
./mysqld --defaults-file=/etc/my.cnf --user=mysql --initialize-insecure
/etc/init.d/mysql start

yum -y install net-tools
yum groupinstall -y "Development tools"
yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel
yum install -y python-devel
wget --no-check-certificat  https://pypi.python.org/packages/source/s/setuptools/setuptools-2.0.tar.gz
tar zxf setuptools-2.0.tar.gz
cd setuptools-2.0
python setup.py install
cd  ..
wget https://pypi.python.org/packages/source/p/pip/pip-1.3.1.tar.gz --no-check-certificate
tar -xzvf pip-1.3.1.tar.gz
cd pip-1.3.1
python setup.py install
python -m pip install --upgrade pip

cd /root/
git clone https://github.com/Tencent/bk-sops.git
cd bk-sops/
pip install -r requirements.txt

mysql -u root -p
##############################################
CREATE DATABASE `bk_sops` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
##############################################

vi /root/bk-sops/scripts/develop/sites/community/env.sh


yum install epel-release
yum install nodejs
cd /root/bk-sops/frontend/desktop/
npm install
npm run build -- --STATIC_ENV=dev

