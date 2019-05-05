#!/usr/bin/env bash
yum -y install gcc gcc-c++ ncurses ncurses-devel cmake systemtap-sdt-devel.x86_64 perl-ExtUtils-Embed readline readline-devel pam pam-devel libxslt libxslt-devel tcl tcl-devel python-devel

wget https://ftp.postgresql.org/pub/source/v11.2/postgresql-11.2.tar.gz
tar -zxvf postgresql-11.2.tar.gz -C /data/soft/
mv /data/soft/postgresql-11.2/ /data/soft/postgresql/
cd /data/soft/postgresql
./configure --prefix=/usr/local/pgsql --without-readline
make && make install

deluser postgres
rm -rf /home/postgres
adduser postgres
chown -R postgres:root /usr/local/pgsql/
mkdir -p /usr/local/pgsql/data
mkdir -p /home/postgres
chown -R postgres:root /usr/local/pgsql/data

echo "export PATH=/usr/local/pgsql/bin:$PATH" >> /etc/profile
echo "export PGDATA=/usr/local/pgsql/data"    >> /etc/profile
echo "export LD_LIBRARY_PATH=/usr/lib:/usr/local/pgsql/lib:/usr/local/lib" >> /etc/profile
source /etc/profile

su postgres
/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data/
/usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data/ > logfile 2>&1 &

/usr/local/pgsql/bin/psql postgres postgres << EOF
ALTER USER postgres WITH PASSWORD '12345678'
\q
EOF

chmod +u+x /data/soft/postgresql/contrib/start-scripts/linux
cp /data/soft/postgresql/contrib/start-scripts/linux /etc/init.d/postgresql
/etc/init.d/postgresql start
service postgresql start