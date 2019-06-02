#!/usr/bin/env bash
# 每个RedHat都有不同版本，不能分发错

wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-v3.4-latest.tgz

tar -xvzf mongodb-linux-x86_64-rhel70-latest.tgz -C /data/soft/
mv /data/soft/mongodb-linux-x86_64-rhel70-4.1.10-309-g4a2b759/ /data/soft/mongodb/
mkdir /data/soft/mongodb/data
mkdir /data/soft/mongodb/log
mkdir /data/soft/mongodb/etc
touch /data/soft/mongodb/log/mongo.log
cat  >> /etc/profile << EOF
export PATH=$PATH:/data/soft/mongodb/bin
EOF
source /etc/profile
chown -R 777 /data/soft/mongodb/data
chown -R 777 /data/soft/mongodb/log
chown -R 777 /data/soft/mongodb/etc
cat  >> /data/soft/mongodb/mongodb.conf << EOF
dbpath=/data/soft/mongodb/data/
logpath=/data/soft/mongodb/log/mongo.log
logappend=true
quiet=true
port=20000
fork=true
bind_ip=0.0.0.0
EOF
/data/soft/mongodb/bin/mongod --config /data/soft/mongodb/mongodb.conf

# 启动mongoDB：/data/soft/mongodb/bin/mongo --port=20000

#mongodb  管理员用户：useradmin  密码：adminpassword
#use admin
#db.createUser({user:"useradmin",pwd:"adminpassword",roles:[{role:"userAdminAnyDatabase",db:"admin"}]})
#db.auth("useradmin","adminpassword")
#pdx  管理员：pdx  密码：123456
#use pdx
#db.createUser({user:"pdx",pwd:"123456",roles:[{role:"dbOwner",db:"pdx"}]})
#db.auth("pdx","123456")
