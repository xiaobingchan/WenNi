#!/usr/bin/env bash

# https://www.cnblogs.com/yypbingo/p/6839555.html
# https://www.cnblogs.com/nika86/p/5222386.html

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

systemctl stop firewalld

yum -y install wget
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.3.1.tar.gz
tar -zxvf elasticsearch-5.3.1.tar.gz  -C /usr/local/
vi /usr/local/elasticsearch-5.3.1/config/elasticsearch.yml
#################################################################
cluster.name: skynet_es_cluster
node.name: skynet_es_cluster_dev1
path.data: /data/elk/data
path.logs: /data/elk/logs
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts:  ["127.0.0.0.1","192.168.56.1"]
http.cors.enabled: true
http.cors.allow-origin: "*"
bootstrap.memory_lock: false
bootstrap.system_call_filter: false
##########################################################################
cat >> /etc/sysctl.conf  << EOF
vm.max_map_count=655360
EOF
sysctl -p
cat >> /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 131072
* soft nproc 65536
* hard nproc 131072
EOF
sysctl -p
cat >> /etc/security/limits.d/20-nproc.conf << EOF
elk    soft    nproc     65536
EOF
useradd elk
groupadd elk
useradd elk -g elk
mkdir  -pv  /data/elk/{data,logs}
chown -R elk:elk /data/elk/
chown -R elk:elk /usr/local/elasticsearch-5.3.1/
su elk
/usr/local/elasticsearch-5.3.1/bin/elasticsearch



wget https://artifacts.elastic.co/downloads/logstash/logstash-5.3.1.tar.gz
tar -zxvf logstash-5.3.1.tar.gz  -C /usr/local/

firewall-cmd --permanent --zone=public --add-port=9200/tcp
firewall-cmd --reload

cat > /usr/local/logstash-5.3.1/config/logstash-test.conf << EOF
input { stdin { } }
output {
elasticsearch {hosts => "127.0.0.1:9200" } #elasticsearch服务地址
stdout { codec=> rubydebug }
}
EOF
/usr/local/logstash-5.3.1/bin/logstash  -f /usr/local/logstash-5.3.1/config/logstash-test.conf
curl 'http://127.0.0.1:9200/_search?pretty'

yum -y install httpd
wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz
tar xfz kibana-3.1.2.tar.gz -C /var/www/html
mv /var/www/html/kibana-3.1.2 /var/www/html/kibana
vi /var/www/html/kibana/config.js
################################################################
elasticsearch:　　"http://127.0.0.1:9200"
################################################################

