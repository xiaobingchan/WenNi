# 易佰教程Hadoop：https://www.yiibai.com/hadoop
# 实验楼：https://www.shiyanlou.com/courses/?category=%E5%85%A8%E9%83%A8&tag=Hadoop&fee=all&sort=default&preview=false

#!/usr/bin/env bash

1，HDFS基本操作：https://www.shiyanlou.com/courses/237/labs/1032/document/#3.1%20%E8%BF%90%E8%A1%8C%E4%BB%A3%E7%A0%81
2，MapReduce操作：https://www.shiyanlou.com/courses/237/labs/1033/document/

HDFS创建文件夹：      hadoop fs -mkdir /user/hadoop
上传本地文件到HDFS：  hadoop fs -put a.txt /user/hadoop/
检测是否上传HDFS成功：hadoop fs -get /user/hadoop/a.txt /
读取HDFS文件内容：    hadoop fs -cat /user/hadoop/a.txt
删除HDFS文件：        hadoop fs -rm /user/hadoop/a.txt

# 报告文件系统的基本信息和统计信息
hadoop dfsadmin -report

vi /usr/local/hadoop/etc/hadoop/log4j.properties
log4j.logger.org.apache.hadoop.util.NativeCodeLoader=ERROR

vi /etc/profile
export HADOOP_CLASSPATH=/root/
javac -classpath /usr/local/hadoop/share/hadoop/common/hadoop-common-2.6.5.jar F:\BiggestData\Testhdat.java


# 配置环境变量
HADOOP_CLASSPATH=F:\BiggestData\Test
# 编译Hadoop java程序
javac -classpath F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\share\hadoop\common\hadoop-common-2.7.7.jar F:\BiggestData\Test\hdat.java
# 运行java程序
F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop fs -put C:\Users\Administrator\Desktop\test.bat /user
F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop hdat /user/test.bat


# 报告文件系统的基本信息和统计信息
hadoop dfsadmin -report



###########################################################
读取HDFS里面的某个文件的内容
F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop fs -put C:\Users\Administrator\Desktop\test.bat /user
F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop hdat /user/test.bat

import java.io.InputStream;
import java.net.URI;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;
import org.apache.hadoop.io.IOUtils;

public class hdat{
    public static void main(String[] args) throws Exception {
        String uri = args[0];
        Configuration conf = new Configuration();
        FileSystem fs = FileSystem. get(URI.create (uri), conf);
        InputStream in = null;
        try {
            in = fs.open( new Path(uri));
            IOUtils.copyBytes(in, System.out, 4096, false);
        } finally {
            IOUtils.closeStream(in);
        }
    }
}


###########################################################
编译：javac -classpath F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\share\hadoop\common\hadoop-common-2.7.7.jar F:\BiggestData\Test\LocalFile2Hdfs.java
运行：F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop LocalFile2Hdfs   C:\Users\Administrator\Desktop\vss.txt /user/vss2.txt
      F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop fs -cat /user/vss2.txt
读取HDFS文件中的某几行，写入到本地文件

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.net.URI;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IOUtils;
import org.apache.hadoop.util.Progressable;

public class LocalFile2Hdfs {
    public static void main(String[] args) throws Exception {

        String local = args[0];
        String uri = args[1];

        FileInputStream in = null;
        OutputStream out = null;
        Configuration conf = new Configuration();
        try {
            in = new FileInputStream(new File(local));

            FileSystem fs = FileSystem.get(URI.create(uri), conf);
            out = fs.create(new Path(uri), new Progressable() {
                @Override
                public void progress() {
                    System.out.println("*");
                }
            });

            in.skip(100);
            byte[] buffer = new byte[20];

            int bytesRead = in.read(buffer);
            if (bytesRead >= 0) {
                out.write(buffer, 0, bytesRead);
            }
        } finally {
            IOUtils.closeStream(in);
            IOUtils.closeStream(out);
        }
    }
}


###########################################################
编译：javac -classpath F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\share\hadoop\common\hadoop-common-2.7.7.jar F:\BiggestData\Test\Hdfs2LocalFile.java
上传：F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop fs -put C:\Users\Administrator\Desktop\vss.txt /user
运行：F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\bin\hadoop Hdfs2LocalFile  /user/vss.txt vss2.txt

读取HDFS文件中的某几行，写入到本地文件

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.net.URI;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IOUtils;

public class Hdfs2LocalFile {
    public static void main(String[] args) throws Exception {

        String uri = args[0];
        String local = args[1];

        FSDataInputStream in = null;
        OutputStream out = null;
        Configuration conf = new Configuration();
        try {
            FileSystem fs = FileSystem.get(URI.create(uri), conf);
            in = fs.open(new Path(uri));
            out = new FileOutputStream(local);

            byte[] buffer = new byte[20];
            in.skip(100);
            int bytesRead = in.read(buffer);
            if (bytesRead >= 0) {
                out.write(buffer, 0, bytesRead);
            }
        } finally {
            IOUtils.closeStream(in);
            IOUtils.closeStream(out);
        }
    }
}





javac -classpath /usr/local/hadoop/share/hadoop/common/hadoop-common-2.6.5.jar F:\BiggestData\Test\hdat.java
Windows启动Hadoop：F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\sbin\start-all.cmd
Windows:javac -classpath F:\BiggestData\hadoop-2.7.7\hadoop-2.7.7\hadoop-2.7.7\share\hadoop\common\hadoop-common-2.7.7.jar F:\BiggestData\Test\hdat.java
