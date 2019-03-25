from kafka import KafkaConsumer

consumer = KafkaConsumer('test',bootstrap_servers=['127.0.0.1:9092'])  #参数为接收主题和kafka服务器地址

# 这是一个永久堵塞的过程，生产者消息会缓存在消息队列中,并且不删除,所以每个消息在消息队列中都有偏移
for message in consumer:  # consumer是一个消息队列，当后台有消息时，这个消息队列就会自动增加．所以遍历也总是会有数据，当消息队列中没有数据时，就会堵塞等待消息带来
    print("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,message.offset, message.key,message.value))
