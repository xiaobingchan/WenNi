#!/usr/bin/env bash

ps aux | grep oracle | awk {'print $2'} | xargs kill -9
lsnrctl stop
mkdir /data/
mkdir /data/soft/
mkdir /data/ioszdhyw/
mkdir /data/ioszdhyw/bin/
mkdir /data/ioszdhyw/conf/
mkdir /data/ioszdhyw/soft/
rm -rf /data/ioszdhyw/soft/app
rm -rf /data/ioszdhyw/soft/database
rm -rf /oracle/
rm -rf /home/oracle/

sed -i "s/HOSTNAME=localhost.localdomain/HOSTNAME=oracledb.01/" /etc/sysconfig/network
IP=$(LC_ALL=C ip addr |grep "inet "|grep -v "127.0.0.1"|awk -F "[/ ]+" '{print $3}')
HOSTNAME=$(hostname)
echo $IP $(hostname) >>/etc/hosts
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
setenforce 0

yum install -y compat-libcap1 binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel gcc glibc-devel libgomp glibc-headers kernel-headers gcc-c++ libstdc++-devel glibc glibc-common ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel unzip bc perl

pkill -9 oracle
groupadd -g 502 oinstall
groupadd -g 503 dba
useradd -u 502 -g oinstall -G dba  oracle
mkdir -p /home/oracle
echo "oracle" | passwd --stdin oracle
rm -rf /data/ioszdhyw/soft/orcl/
chmod -R 777 /data/ioszdhyw/soft/
mkdir -p /data/ioszdhyw/soft/app/
chown -R oracle:oinstall /data/ioszdhyw/soft/app/
chmod -R 777 /data/ioszdhyw/soft/app/
chmod -R 777 /tmp/

#sysctl.conf
TOTALMEM=`free -m 2>/dev/null | grep Mem|awk '{print $2}'`
SGA=$[$TOTALMEM*7*8/100]
PGA=`echo $SGA|awk '{ printf "%0.0f\n" ,($1*0.1)}'`
SHMMAX=`echo $SGA|awk '{ printf "%0.0f\n" ,($1+100)*1024*1024}'`
PAGE_SIZE=`getconf PAGE_SIZE`
SHMALL=$[$SHMMAX/$PAGE_SIZE]
cp /etc/sysctl.conf{,.ora_bak}
sed -i s/'kernel.shmmax'/'#kernel.shmmax'/ /etc/sysctl.conf
sed -i s/'kernel.shmall'/'#kernel.shmall'/ /etc/sysctl.conf
cat  >> /etc/sysctl.conf << EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912   #最低：536870912，最大值：比物理内存小1个字节的值，建议超过物理内存的一半
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
/sbin/sysctl -p
#limits
echo "oracle soft nproc 2047  ">>/etc/security/limits.conf
echo "oracle hard nproc 16384  ">>/etc/security/limits.conf
echo "oracle soft nofile 1024  ">>/etc/security/limits.conf
echo "oracle hard nofile 65536  ">>/etc/security/limits.conf
echo "oracle soft stack 10240  ">>/etc/security/limits.conf
echo "oracle hard stack 10240  ">>/etc/security/limits.conf
#profile
echo "if [ $USER = "oracle" ]; then  ">>/etc/profile
echo "   if [ $SHELL = "/bin/ksh" ]; then  ">>/etc/profile
echo "       ulimit -p 16384  ">>/etc/profile
echo "       ulimit -n 65536  ">>/etc/profile
echo "   else  ">>/etc/profile
echo "       ulimit -u 16384 -n 65536  ">>/etc/profile
echo "   fi  ">>/etc/profile
echo "fi  ">>/etc/profile
source /etc/profile


unzip -o /data/soft/p13390677_112040_Linux-x86-64_1of7.zip -d /data/ioszdhyw/soft
unzip -o /data/soft/p13390677_112040_Linux-x86-64_2of7.zip -d /data/ioszdhyw/soft

#db_rsp
#输入用户密码,SID
password=d2efe1fc078#f992
SID=orcl
ORAPATH=/data/ioszdhyw/soft
ORAALLPASS=d2efe1fc078#f992
CHARACTER=ZHS16GBK
ORACLE_HOME=$ORAPATH/app/oracle/product/11.2.0/db_1
cat> ${ORAPATH}/db.rsp << EOF
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=$(hostname)
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=$ORAPATH/app/oraInventory
SELECTED_LANGUAGES=en,zh_CN
ORACLE_HOME=$ORACLE_HOME
oracle.install.db.InstallEdition=EE
oracle.install.db.isCustomInstall=false
oracle.install.db.customComponents=oracle.server:11.2.0.1.0,oracle.sysman.ccr:10.2.7.0.0,oracle.xdk:11.2.0.1.0,oracle.rdbms.oci:11.2.0.1.0,oracle.network:11.2.0.1.0,oracle.network.listener:11.2.0.1.0,oracle.rdbms:11.2.0.1.0,oracle.options:11.2.0.1.0,oracle.rdbms.partitioning:11.2.0.1.0,oracle.oraolap:11.2.0.1.0,oracle.rdbms.dm:11.2.0.1.0,oracle.rdbms.dv:11.2.0.1.0,orcle.rdbms.lbac:11.2.0.1.0,oracle.rdbms.rat:11.2.0.1.0
oracle.install.db.DBA_GROUP=oinstall
oracle.install.db.OPER_GROUP=oinstall
oracle.install.db.CLUSTER_NODES=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=$SID
oracle.install.db.config.starterdb.SID=$SID
oracle.install.db.config.starterdb.characterSet=AL32UTF8
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.enableSecuritySettings=true
oracle.install.db.config.starterdb.password.ALL=$ORAALLPASS
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.SYSMAN=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.control=DB_CONTROL
oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false
oracle.install.db.config.starterdb.dbcontrol.emailAddress=
oracle.install.db.config.starterdb.dbcontrol.SMTPServer=
oracle.install.db.config.starterdb.automatedBackup.enable=false
oracle.install.db.config.starterdb.automatedBackup.osuid=
oracle.install.db.config.starterdb.automatedBackup.ospwd=
oracle.install.db.config.starterdb.storageType=
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
EOF

PORT=1521
ORAPATH=/data/ioszdhyw/soft
cat> ${ORAPATH}/netca.rsp << EOF
[GENERAL]
RESPONSEFILE_VERSION="11.2"
CREATE_TYPE="CUSTOM"
[oracle.net.ca]
INSTALLED_COMPONENTS={"server","net8","javavm"}
INSTALL_TYPE=""typical""
LISTENER_NUMBER=1
LISTENER_NAMES={"LISTENER"}
LISTENER_PROTOCOLS={"TCP;$PORT"}
LISTENER_START=""LISTENER""
NAMING_METHODS={"TNSNAMES","ONAMES","HOSTNAME"}
NSN_NUMBER=1
NSN_NAMES={"EXTPROC_CONNECTION_DATA"}
NSN_SERVICE={"PLSExtProc"}
NSN_PROTOCOLS={"TCP;HOSTNAME;$PORT"}
EOF

ORAPATH=/data/ioszdhyw/soft
DATAPATH=/data/ioszdhyw/soft
SID=orcl
HOSTNAME=$(hostname)
TOTALMEM=`free -m 2>/dev/null | grep Mem|awk '{print $2}'`
ORAMEM=$[$TOTALMEM*6/10]
HOSTNAME=$(hostname)
CHARACTER=ZHS16GBK
ORACLE_HOME=$ORAPATH/app/oracle/product/11.2.0/db_1
ORASYSPASS="d2efe1fc078#f992"
ORASYSTEMPASS="d2efe1fc078#f992"
cat> ${ORAPATH}/dbca.rsp << EOF
[GENERAL]
RESPONSEFILE_VERSION = "11.2.0"
OPERATION_TYPE = "CREATEDATABASE"
[CREATEDATABASE]
GDBNAME = "$SID"
SID = "$SID"
TEMPLATENAME ="General_Purpose.dbc"
SYSPASSWORD="$ORASYSPASS"
SYSTEMPASSWORD="$ORASYSTEMPASS"
DATAFILEJARLOCATION ="$ORACLE_HOME/assistants/dbca/templates"
NODELIST="$HOSTNAME"
CHARACTERSET="$CHARACTER"
OBFUSCATEDPASSWORDS="FALSE"
SAMPLESCHEMA="FALSE"
DATAFILEDESTINATION="$DATAPATH"
REDOLOGFILESIZE="1024"
TOTALMEMORY="$ORAMEM"
DATABASETYPE="OLTP"
EOF

cat  >> /etc/profile << EOF
export ORACLE_BASE=/data/ioszdhyw/soft/app/oracle
export ORACLE_SID=orcl
export ORACLE_PID=ora11g
#export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
export ORACLE_HOME=/data/ioszdhyw/soft/app/oracle/product/11.2.0/db_1
export PATH=$PATH:$ORACLE_HOME/bin
export LANG="zh_CN.UTF-8"
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.AL32UTF8"
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
EOF
source /etc/profile

ORAPATH=/data/ioszdhyw/soft
chown oracle:oinstall ${ORAPATH}/db.rsp
chmod 777 ${ORAPATH}/db.rsp
chown oracle:oinstall ${ORAPATH}/netca.rsp
chmod 777 ${ORAPATH}/netca.rsp
chown oracle:oinstall ${ORAPATH}/dbca.rsp
chmod 777 ${ORAPATH}/dbca.rsp

ORAPATH=/data/ioszdhyw/soft
su - oracle -c "sh $ORAPATH/database/runInstaller -ignorePrereq -silent -force -responseFile $ORAPATH/db.rsp"
declare -i p1
sum=0
while(($sum<=10))
do
    sleep 1
        if [ $sum -gt 3 ]
        then
            echo 'ok' >> /home/oracle/dbinstall_log.txt
            p1=`ps -ef|grep oracle.installer |grep -v "grep" |awk '{print $2}'`
            if [ $p1 -eq 0 ]
            then
                echo 'the Script of db_install execution completed'
                sleep 1
                break
            fi
            sum=1
    fi
    echo $sum >> /home/oracle/dbinstall_log.txt
let "sum++"
done
cat  >> ~/.bash_profile << EOF
export ORACLE_BASE=/data/ioszdhyw/soft/app/oracle
export ORACLE_SID=orcl
export ORACLE_PID=ora11g
#export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
export ORACLE_HOME=/data/ioszdhyw/soft/app/oracle/product/11.2.0/db_1
export PATH=$PATH:$ORACLE_HOME/bin
export LANG="zh_CN.UTF-8"
export NLS_LANG="SIMPLIFIED CHINESE_CHINA.AL32UTF8"
export NLS_DATE_FORMAT='yyyy-mm-dd hh24:mi:ss'
EOF
source ~/.bash_profile
lsnrctl stop
ORAPATH=/data/ioszdhyw/soft
DATAPATH=/data/ioszdhyw/soft
su - oracle -c "sh ${DATAPATH}/app/oracle/product/11.2.0/db_1/bin/netca /silent /responsefile ${ORAPATH}/netca.rsp"
declare -i p2
sum2=0
while(($sum2<=10))
do
    sleep 1
        if [ $sum2 -gt 3 ]
        then
            echo 'ok' >>/home/oracle/neca_log.txt
            p2=`ps -ef|grep netca |grep -v "grep" |awk '{print $2}'`
            if [ $p2 -eq 0 ]
            then
                echo 'the Script of netca_install execution completed'
                sleep 3
                #dbca
                break
            fi
            sum2=1
    fi
      echo $sum2 >> /home/oracle/netca_log.txt
let "sum2++"
done
ORAPATH=/data/ioszdhyw/soft
DATAPATH=/data/ioszdhyw/soft
su - oracle -c "sh ${DATAPATH}/app/oracle/product/11.2.0/db_1/bin/dbca -silent -responseFile ${ORAPATH}/dbca.rsp"
declare -i p3
sum3=0
while(($sum3<=10))
do
    sleep 1
        if [ $sum3 -gt 3 ]
        then
            echo 'ok' >> /home/oracle/dbca_log.txt
            p3=`ps -ef|grep dbca |grep -v "grep" |awk '{print $2}'`
            if [ $p3 -eq 0 ]
            then
                echo 'the Script of dbca_install execution completed'
                sleep 1
                # set_env
               # runrootsh
                break
            fi
            sum3=1
    fi
    echo $sum3 >> /home/oracle/dbca_log.txt
let "sum3++"
done

rm -rf /data/ioszdhyw/bin/sqlplus > /dev/null 2>&1
ln -s /data/ioszdhyw/soft/app/oracle/product/11.2.0/db_1/bin/sqlplus /data/ioszdhyw/bin/sqlplus > /dev/null 2>&1
rm -rf /data/ioszdhyw/bin/lsnrctl > /dev/null 2>&1
ln -s /data/ioszdhyw/soft/app/oracle/product/11.2.0/db_1/bin/lsnrctl /data/ioszdhyw/bin/lsnrctl > /dev/null 2>&1
USERNAME='sys'
PASSWORD='d2efe1fc078#f992'
oracle_database='orcl'
new_username='ioszdhyw'
new_password='d2efe1fc078#f992'
lsnrctl start
sqlplus /nolog <<EOF
set heading off;
set feedback off;
set pagesize 0;
set verify off;
set echo off;
conn $USERNAME/$PASSWORD as sysdba
startup;
create user $new_username identified by $new_password default tablespace USERS temporary tablespace TEMP;
grant connect to $new_username;
grant dba to $new_username;
grant create session to $new_username;
exit;
EOF
cat  >> /etc/sysconfig/selinux  << EOF
SELINUX=disabled
EOF
linux_centos=`cat /etc/redhat-release | grep "release 6" | wc -l`
linux_centos=`echo ${linux_centos}| awk '{print int($0)}'`
if [ $linux_centos -eq 1 ]
then
line_number_raw=`grep -rn 'INPUT' "/etc/sysconfig/iptables"`
line_number=${line_number_raw%:*}
line_number=`echo ${line_number}| awk '{print int($0)}'`
if [ $line_number -gt 1 ]
then
redis_config_content="-A INPUT -m state --state NEW -m tcp -p tcp --dport 1521 -j ACCEPT"
add_text=`sed -i "${line_number}"i"${redis_config_content}" "/etc/sysconfig/iptables"`
service iptables restart
fi
else
firewall-cmd --zone=public --add-port=1521/tcp --permanent
firewall-cmd --reload
fi
if [ $? -eq 0 ]
then
    echo -ne "["
    echo -ne "{"\"instance_name"\":{"\"value"\":"\"$oracle_database"\","\"unit"\":"\""\","\"status"\":"\""\"}}",
    echo -ne "{"\"sys password"\":{"\"value"\":"\"$PASSWORD"\","\"unit"\":"\""\","\"status"\":"\""\"}}",
    echo -ne "]"
else
    echo "{'oracle11g-install':{'value':'oracle11g install fail','unit':'','status':'1'}}"
fi

