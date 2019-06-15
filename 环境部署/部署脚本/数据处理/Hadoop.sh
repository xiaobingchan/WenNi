#!/usr/bin/env bash

# Windows安装部署：https://blog.csdn.net/xiligey1/article/details/79728152
# CentOS安装部署：https://www.linuxidc.com/Linux/2018-06/152795.htm

rpm -ivh jdk-8u152-linux-x64.rpm  # 安装jdk到目录/usr/local
pid="sed -i '/export JAVA_HOME/d' /etc/profile"
eval $pid # 删除已经存在的JAVA_HOME环境变量
pid="sed -i '/export CLASSPATH/d' /etc/profile"
eval $pid # 删除已经存在的CLASSPATH环境变量
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile # 刷新环境变量

yum -y install openssh-server
vi /etc/ssh/sshd_config
#############################
PermitRootLogin yes
#############################
systemctl restart sshd
cd  ~/.ssh/
ssh-keygen -t rsa
cat /root/.ssh/id_rsa >> /root/.ssh/authorized_keys
ssh localhost

wget http://mirrors.hust.edu.cn/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5.tar.gz
tar -zxvf  hadoop-2.6.5.tar.gz -C /usr/local
cd /usr/local
mv hadoop-2.6.5/ hadoop/
cat >> /etc/profile <<EOF
export HADOOP_HOME=/usr/local/hadoop
export CLASSPATH=\$(\$HADOOP_HOME/bin/hadoop classpath):\$CLASSPATH
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile # 刷新环境变量

cat >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh<<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
EOF

vi /usr/local/hadoop/etc/hadoop/core-site.xml <<EOF
<configuration>
        <property>
             <name>hadoop.tmp.dir</name>
             <value>file:/usr/local/hadoop/tmp</value>
             <description>Abase for other temporary directories.</description>
        </property>
        <property>
             <name>fs.defaultFS</name>
             <value>hdfs://localhost:9000</value>
        </property>
</configuration>
EOF

vi /usr/local/hadoop/etc/hadoop/hdfs-site.xml <<EOF
<configuration>
        <property>
             <name>dfs.replication</name>
             <value>1</value>
        </property>
        <property>
             <name>dfs.namenode.name.dir</name>
             <value>file:/usr/local/hadoop/tmp/dfs/name</value>
        </property>
        <property>
             <name>dfs.datanode.data.dir</name>
             <value>file:/usr/local/hadoop/tmp/dfs/data</value>
        </property>
</configuration>
EOF

cat >> /usr/local/hadoop/etc/hadoop/log4j.properties <<EOF
log4j.logger.org.apache.hadoop.util.NativeCodeLoader=ERROR
EOF
systemctl stop firewalld

/usr/local/hadoop/bin/hdfs namenode -format
sh /usr/local/hadoop/sbin/start-dfs.sh
curl -I http://localhost:50070 # http://192.168.56.1:50070
jps

############################################################################################

wget http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz
wget https://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.msi
wget https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
git clone https://github.com/steveloughran/winutils.git

vi F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\etc\hadoop\core-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/F:/BiggestData/hadoop-2.7.7/hadoop-2.7.7/workplace/temp</value>
    </property>
    <property>
        <name>dfs.name.dir</name>
        <value>/F:/BiggestData/hadoop-2.7.7/hadoop-2.7.7/workplace/name</value>
    </property>
    <property>
        <name>fs.default.name</name>
        <value>hdfs://localhost:9000</value>
    </property>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>
EOF

vi F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\etc\hadoop\mapred-site.xml << EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
       <name>mapreduce.framework.name</name>
       <value>yarn</value>
    </property>
    <property>
       <name>mapred.job.tracker</name>
       <value>hdfs://localhost:9001</value>
    </property>
</configuration>
EOF

vi F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\etc\hadoop\hdfs-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <!-- 这个参数设置为1，因为是单机版hadoop -->
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.data.dir</name>
        <value>/F:/BiggestData/hadoop-2.7.7/hadoop-2.7.7/workplace/data</value>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/F:/BiggestData/hadoop-2.7.7/hadoop-2.7.7/workplace/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/F:/BiggestData/hadoop-2.7.7/hadoop-2.7.7/workplace/data</value>
    </property>
</configuration>
EOF

vi F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\etc\hadoop\yarn-site.xml << EOF
<?xml version="1.0"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<configuration>
    <property>
       <name>yarn.nodemanager.aux-services</name>
       <value>mapreduce_shuffle</value>
    </property>
    <property>
       <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
       <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
</configuration>
EOF


vi F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\etc\hadoop\hadoop-env.cmd << EOF
set JAVA_HOME=C:\Java\jdk1.8.0_192
EOF

md F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\workplace\
md F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\workplace\temp
md F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\workplace\data
md F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\workplace\name

wmic ENVIRONMENT where "name='HADOOP_HOME'" delete
wmic ENVIRONMENT create name="HADOOP_HOME",username="<system>",VariableValue="F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7"
wmic ENVIRONMENT where "name='Path' and username='<system>'" set VariableValue="%Path%;F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin"

# 复制 bin/ 目录的 hadoop和yarn到 sbin/ 目录

F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hdfs namenode -format
F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\sbin\start-all.cmd
F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\jps

Hadoop
Windows安装部署：https://blog.csdn.net/xiligey1/article/details/79728152
e:
cd E:\MyWeb\hadoop-2.7.5\hadoop-2.7.5\sbin
start-all.cmd
http://localhost:8088/cluster
http://localhost:50070/dfshealth.html#tab-overview

Spark
Windows安装部署：https://blog.csdn.net/xiligey1/article/details/79728987