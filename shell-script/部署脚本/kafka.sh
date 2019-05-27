#!/usr/bin/env bash

# kafka中文文档：http://kafka.apachecn.org/

rpm -ivh jdk-8u152-linux-x64.rpm
pid="sed -i '/export JAVA_HOME/d' /etc/profile"
eval $pid
pid="sed -i '/export CLASSPATH/d' /etc/profile"
eval $pid
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/java/jdk1.8.0_152
export CLASSPATH=%JAVA_HOME%/lib:%JAVA_HOME%/jre/lib
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
source /etc/profile

wget https://archive.apache.org/dist/kafka/1.0.0/kafka_2.11-1.0.0.tgz
tar -zxvf kafka_2.11-1.0.0.tgz -C /usr/local/
cd /usr/local/kafka_2.11-1.0.0/
sh bin/zookeeper-server-start.sh -daemon config/zookeeper.properties
sh bin/kafka-server-start.sh config/server.properties
sh bin/kafka-topics.sh --create --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1 --topic test2
sh bin/kafka-console-consumer.sh --zookeeper 127.0.0.1:2181 --topic test2 --from-beginning
sh bin/kafka-console-producer.sh --broker-list 127.0.0.1:9092 --topic test2

import json
from kafka import KafkaProducer
producer = KafkaProducer(bootstrap_servers='localhost:9092')
msg_dict = {
    "sleep_time": 10,
    "db_config": {
        "database": "test_1",
        "host": "xxxx",
        "user": "root",
        "password": "root"
    },
    "table": "msg",
    "msg": "Hello World"
}
msg = json.dumps(msg_dict)
producer.send('test3', bytes(msg,'ascii'), partition=0)
producer.close()

from kafka import KafkaConsumer
consumer = KafkaConsumer('test3', bootstrap_servers=['localhost:9092'])
for msg in consumer:
    recv = "%s:%d:%d: key=%s value=%s" % (msg.topic, msg.partition, msg.offset, msg.key, msg.value)
    print(recv)