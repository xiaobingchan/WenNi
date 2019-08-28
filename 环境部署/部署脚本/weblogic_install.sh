#!/usr/bin/env bash

rpm -ivh jdk-8u152-linux-x64.rpm
pid="sed -i '/export JAVA_HOME/d' /etc/profile"
eval $pid
pid="sed -i '/export CLASSPATH/d' /etc/profile"
eval $pid
mv /usr/bin/java /usr/bin/java_kkk  # 卸载自带的 openjdk
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile  > /dev/null 2>&1


mkdir -p /home/weblogic
groupadd weblogic
useradd -g weblogic weblogic
echo "123456" | passwd weblogic --stdin
chown -R oinstall:weblogic /home/weblogic
chmod -R 777 /home/weblogic
chmod -R 777 /tmp
chmod -R 777 /home/weblogic/fmw_12.2.1.3.0_wls.jar

su - weblogic
cat >> ~/.bash_profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source ~/.bash_profile  > /dev/null 2>&1

cat > /home/weblogic/wls.rsp <<EOF
[ENGINE]

#DO NOT CHANGE THIS.

Response File Version=1.0.0.0.0

[GENERIC]
#The oracle home location. This can be an existing Oracle Home or a new Oracle Home

ORACLE_HOME=/home/weblogic/Oracle

#Set this variable value to the Installation Type selected. e.g. WebLogic Server, Coherence, Complete with Examples.

INSTALL_TYPE=WebLogic Server

#Provide the My Oracle Support Username. If you wish to ignore Oracle Configuration Manager configuration provide empty string for user name.

MYORACLESUPPORT_USERNAME=

#Provide the My Oracle Support Password

MYORACLESUPPORT_PASSWORD=<SECURE VALUE>

#Set this to true if you wish to decline the security updates. Setting this to true and providing empty string for My Oracle Support username will ignore the Oracle Configuration Manager configuration

DECLINE_SECURITY_UPDATES=true

#Set this to true if My Oracle Support Password is specified

SECURITY_UPDATES_VIA_MYORACLESUPPORT=false

#Provide the Proxy Host

PROXY_HOST=

#Provide the Proxy Port

PROXY_PORT=

#Provide the Proxy Username

PROXY_USER=

#Provide the Proxy Password

PROXY_PWD=<SECURE VALUE>

#Type String (URL format) Indicates the OCM Repeater URL which should be of the format [scheme[Http/Https]]://[repeater host]:[repeater port]

COLLECTOR_SUPPORTHUB_URL=
EOF


cat  > /home/weblogic/oraInst.loc << EOF
inventory_loc=/home/weblogic/oraInventory

inst_group=weblogic
EOF

su - weblogic << EOF
java -jar fmw_12.2.1.3.0_wls.jar  -silent  -responseFile  /home/weblogic/wls.rsp  -invPtrLoc /home/weblogic/oraInst.loc
EOF

cd /home/weblogic/Oracle
mkdir -p user_projects/domains/base_domain
cd user_projects/domains/base_domain
cp /home/weblogic/Oracle/wlserver/common/templates/scripts/wlst/basicWLSDomain.py /home/weblogic/Oracle/user_projects/domains/base_domain/basicWLSDomain.py

vi /home/weblogic/Oracle/user_projects/domains/base_domain/basicWLSDomain.py
#########################################################

# Please set password here before using this script, e.g. cmo.setPassword('value')
cmo.setPassword('12345678')
# 删除删除删除删除
# Create a JMS Server.
# 到
# Write the domain and close the domain template.
# 删除删除删除删除

/home/weblogic/Oracle/oracle_common/common/bin/wlst.sh basicWLSDomain.py .
sh /home/weblogic/Oracle/user_projects/domains/basicWLSDomain/bin/startWebLogic.sh

firewall-cmd --zone=public --add-port=7001/tcp --permanent
firewall-cmd --reload