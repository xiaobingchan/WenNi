#!/usr/bin/env bash
# 教程：https://github.com/Tencent/bk-PaaS/blob/master/docs/install/ce_paas_install.md
# Agent：https://github.com/Tencent/bk-PaaS/blob/master/docs/install/ce_paas_agent_install.md

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
default_authentication_plugin=mysql_native_password
bind-address=0.0.0.0
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

mysql -u root -p
######################
CREATE DATABASE IF NOT EXISTS open_paas DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
######################
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

systemctl stop firewalld

cd /root
git clone https://github.com/Tencent/bk-PaaS.git
cd /root/bk-PaaS/paas-ce/paas/paas/
pip install -r requirements.txt
cat > conf/settings_development.py << EOF
PAAS_DOMAIN = '192.168.59.104:8001'
# 跳转到本地开发使用的login服务, 仅本地开发用. 注意生产环境使用nginx反向代理不需要配置LOGIN_DOMAIN变量(删除即可)
LOGIN_DOMAIN = '192.168.59.104:8003'
PAAS_INNER_DOMAIN = ''
# cookie访问域
BK_COOKIE_DOMAIN = '192.168.59.104'
# 控制台地址
ENGINE_HOST = "http://127.0.0.1:8000"
# 登陆服务地址
LOGIN_HOST = "http://127.0.0.1:8003"
# host for cc
HOST_CC = ''
# host for job
HOST_JOB = ''
# host for DATA，数据平台监控告警系统
HOST_DATA = ''
# host for gse
HOST_GSE = ''
EOF
python manage.py migrate
python manage.py runserver 8001

cd /root/bk-PaaS/paas-ce/paas/login/
pip install -r requirements.txt
cat >  conf/settings_development.py << EOF
PAAS_INNER_DOMAIN = ''
BK_COOKIE_DOMAIN = '192.168.59.104'
EOF
python manage.py migrate
python manage.py runserver 8003

cd /root/bk-PaaS/paas-ce/paas/appengine/
pip install -r requirements.txt
cat >   controller/settings.py<< EOF

EOF
python manage.py runserver 8000

cd /root/bk-PaaS/paas-ce/paas/esb/
pip install -r requirements.txt
cp configs/default_template.py  configs/default.py
vi configs/default.py
###################################################

###################################################
python manage.py runserver 8002

cat /root/bk-PaaS/paas-ce/paas/paas/logs/paas.log
cat /root/bk-PaaS/paas-ce/paas/login/logs/login.log
cat /root/bk-PaaS/paas-ce/paas/appengine/logs/appengine.log
cat /root/bk-PaaS/paas-ce/paas/esb/logs/esb.log


docker pull ccr.ccs.tencentyun.com/bk.io/paas-standalone:latest
docker run -d --name="bk-paas" -p 8000-8003:8000-8003 ccr.ccs.tencentyun.com/bk.io/paas-standalone:latest
docker exec -it 2f356ce52de6 /bin/sh
