# 易佰教程Hadoop：https://www.yiibai.com/hadoop
# 实验楼：https://www.shiyanlou.com/courses/?category=%E5%85%A8%E9%83%A8&tag=Hadoop&fee=all&sort=default&preview=false

#!/usr/bin/env bash
hadoop fs -mkdir /user/hadoop
hadoop fs -put a.txt /user/hadoop/
hadoop fs -get /user/hadoop/a.txt /
hadoop fs -cp src dst
hadoop fs -mv src dst
hadoop fs -cat /user/hadoop/a.txt
hadoop fs -rm /user/hadoop/a.txt
hadoop fs -rmr /user/hadoop/a.txt
hadoop fs -text /user/hadoop/a.txt
hadoop fs -copyFromLocal localsrc dst
hadoop fs -moveFromLocal localsrc dst

# 报告文件系统的基本信息和统计信息
hadoop dfsadmin -report


