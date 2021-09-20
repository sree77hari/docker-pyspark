FROM java:8-jdk-alpine

# PYTHON 3

ENV PYTHON_VERSION 3.4.3-r2
ENV ALPINE_OLD_VERSION 3.2
# Hack: using older alpine version to install specific python version
RUN sed -n \
    's|^http://dl-cdn\.alpinelinux.org/alpine/v\([0-9]\+\.[0-9]\+\)/main$|\1|p' \
    /etc/apk/repositories > curr_version.tmp && \
    sed -i 's|'$(cat curr_version.tmp)'/main|'$ALPINE_OLD_VERSION'/main|' \
    /etc/apk/repositories
# Installing given python3 version
RUN apk update && \
    apk add python3=$PYTHON_VERSION
# Reverting hack
RUN sed -i 's|'$(cat curr_version.tmp)'/main|'$ALPINE_OLD_VERSION'/main|' \
    /etc/apk/repositories && \
    rm curr_version.tmp
# Upgrading pip to the last compatible version
RUN pip3 install --upgrade pip

# GENERAL DEPENDENCIES

RUN apk update && \
    apk add curl && \
    apk add bash

# HADOOP

ENV HADOOP_VERSION 2.7.2
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN wget http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -vxzf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/hadoop-$HADOOP_VERSION && \
    rm -rf $HADOOP_HOME/share/doc

# SPARK
RUN apk --no-cache add ca-certificates openssl libstdc++ && update-ca-certificates
ENV SPARK_VERSION 2.4.0
ENV SPARK_PACKAGE spark-$SPARK_VERSION-bin-without-hadoop
ENV SPARK_HOME /usr/spark-$SPARK_VERSION
ENV PYSPARK_PYTHON python3
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:$SPARK_HOME/bin
RUN wget https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-without-hadoop.tgz && \
    tar -xvzf spark-2.4.0-bin-without-hadoop.tgz && \
    mv $SPARK_PACKAGE $SPARK_HOME && \
    rm -rf $SPARK_HOME/examples $SPARK_HOME/ec2
#https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-without-hadoop.tgz
WORKDIR /$SPARK_HOME
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
