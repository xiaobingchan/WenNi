#!/usr/bin/env bash

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

wget https://archive.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-2.3.0-bin.tar.gz # 下载pulsar安装包
tar xvfz apache-pulsar-2.1.1-incubating-bin.tar.gz # 解压安装包
cd apache-pulsar-2.3.0 # 打开pulsar目录
bin/pulsar standalone  # 启动单机pulsar
bin/pulsar-client produce my-topic --messages "hello-pulsar" # 发送一条消息


# ./pip3 install pulsar-client==2.3.1
import pulsar
client = pulsar.Client('pulsar://localhost:6650')
producer = client.create_producer('my-topic')
for i in range(10):
	producer.send(('Hello-%d' % i).encode('utf-8'))
client.close()

# ./pip3 install pulsar-client==2.3.1
import pulsar
client = pulsar.Client('pulsar://localhost:6650')
consumer = client.subscribe('my-topic', 'my-subscription')
while True:
    msg = consumer.receive()
    try:
        print("Received message '{}' id='{}'".format(msg.data(), msg.message_id()))
        consumer.acknowledge(msg)
    except:
        consumer.negative_acknowledge(msg)
client.close()