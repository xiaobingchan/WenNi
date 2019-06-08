#!/usr/bin/env bash

#教程：http://www.ityouknow.com/mongodb/2017/08/05/mongodb-cluster-setup.html

wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.4.21-rc0.tgz
tar -xzvf mongodb-linux-x86_64-rhel70-3.4.21-rc0.tgz -C /usr/local/
cd /usr/local/
mv mongodb-linux-x86_64-rhel70-3.4.21-rc0/ mongodb/
mkdir -p /usr/local/mongodb/conf
mkdir -p /usr/local/mongodb/mongos/log
mkdir -p /usr/local/mongodb/config/data
mkdir -p /usr/local/mongodb/config/log
mkdir -p /usr/local/mongodb/shard1/data
mkdir -p /usr/local/mongodb/shard1/log
mkdir -p /usr/local/mongodb/shard2/data
mkdir -p /usr/local/mongodb/shard2/log
mkdir -p /usr/local/mongodb/shard3/data
mkdir -p /usr/local/mongodb/shard3/log
cat >> /etc/profile <<EOF
export MONGODB_HOME=/usr/local/mongodb
export PATH=\$PATH:\$MONGODB_HOME/bin
EOF
source /etc/profile
cat > /usr/local/mongodb/conf/config.conf <<EOF
pidfilepath = /usr/local/mongodb/config/log/configsrv.pid
dbpath = /usr/local/mongodb/config/data
logpath = /usr/local/mongodb/config/log/congigsrv.log
logappend = true
bind_ip = 0.0.0.0
port = 21000
fork = true
configsvr = true
replSet=configs
maxConns=20000
EOF
mongod -f /usr/local/mongodb/conf/config.conf

mongo --port 21000
######################################################################
config = {
...    _id : "configs",
...     members : [
...         {_id : 0, host : "10.0.2.15:21000" },
...         {_id : 1, host : "192.168.56.2:21000" },
...         {_id : 2, host : "192.168.56.3:21000" }
...     ]
... }
rs.initiate(config)
##########################################################################


cat > /usr/local/mongodb/conf/shard1.conf <<EOF
pidfilepath = /usr/local/mongodb/shard1/log/shard1.pid
dbpath = /usr/local/mongodb/shard1/data
logpath = /usr/local/mongodb/shard1/log/shard1.log
logappend = true
bind_ip = 0.0.0.0
port = 27001
fork = true
httpinterface=true
rest=true
replSet=shard1
shardsvr = true
maxConns=20000
EOF
mongod -f /usr/local/mongodb/conf/shard1.conf

mongo --port 27001
##########################################################################
use admin
config = {
...    _id : "shard1",
...     members : [
...         {_id : 0, host : "192.168.56.1:27001" },
...         {_id : 1, host : "192.168.56.2:27001" },
...         {_id : 2, host : "192.168.56.3:27001" , arbiterOnly: true }
...     ]
... }
rs.initiate(config);
##########################################################################


cat > /usr/local/mongodb/conf/shard2.conf <<EOF
pidfilepath = /usr/local/mongodb/shard2/log/shard2.pid
dbpath = /usr/local/mongodb/shard2/data
logpath = /usr/local/mongodb/shard2/log/shard2.log
logappend = true
bind_ip = 0.0.0.0
port = 27002
fork = true
httpinterface=true
rest=true
replSet=shard2
shardsvr = true
maxConns=20000
EOF
mongod -f /usr/local/mongodb/conf/shard2.conf
mongo --port 27002
##########################################################################
use admin
config = {
...    _id : "shard2",
...     members : [
...         {_id : 0, host : "192.168.56.1:27002"  , arbiterOnly: true },
...         {_id : 1, host : "192.168.56.2:27002" },
...         {_id : 2, host : "192.168.56.3:27002" }
...     ]
... }
rs.initiate(config);
##########################################################################

cat > /usr/local/mongodb/conf/shard3.conf <<EOF
pidfilepath = /usr/local/mongodb/shard3/log/shard3.pid
dbpath = /usr/local/mongodb/shard3/data
logpath = /usr/local/mongodb/shard3/log/shard3.log
logappend = true
bind_ip = 0.0.0.0
port = 27003
fork = true
httpinterface=true
rest=true
replSet=shard3
shardsvr = true
maxConns=20000
EOF
mongod -f /usr/local/mongodb/conf/shard3.conf
mongo --port 27003
##########################################################################
use admin
config = {
...    _id : "shard3",
...     members : [
...         {_id : 0, host : "192.168.56.1:27003" },
...         {_id : 1, host : "192.168.56.2:27003" , arbiterOnly: true},
...         {_id : 2, host : "192.168.56.3:27003" }
...     ]
... }
rs.initiate(config);
##########################################################################

cat > /usr/local/mongodb/conf/mongos.conf <<EOF
pidfilepath = /usr/local/mongodb/mongos/log/mongos.pid
logpath = /usr/local/mongodb/mongos/log/mongos.log
logappend = true
bind_ip = 0.0.0.0
port = 20000
fork = true
configdb = configs/192.168.56.1:21000,192.168.56.2:21000,192.168.56.3:21000
maxConns=20000
EOF
mongos -f /usr/local/mongodb/conf/mongos.conf
mongo --port 20000
##########################################################################
use  admin
sh.addShard("shard1/192.168.56.1:27001,192.168.56.2:27001,192.168.56.3:27001")
sh.addShard("shard2/192.168.56.1:27002,192.168.56.2:27002,192.168.56.3:27002")
sh.addShard("shard3/192.168.56.1:27003,192.168.56.2:27003,192.168.56.3:27003")
sh.status()
db.runCommand( { enablesharding :"testdb"});
db.runCommand( { shardcollection : "testdb.table1",key : {id: 1} } )
##########################################################################

mongo  127.0.0.1:20000
##########################################################################
use  testdb;
for (var i = 1; i <= 100000; i++)
db.table1.save({id:i,"test1":"testval1"});
db.table1.stats();
##########################################################################

