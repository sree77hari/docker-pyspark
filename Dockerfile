FROM debian:stretch

RUN apt-get update \
 && apt-get install -y wget vim openjdk-8-jdk locales fish man-db nano \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# HADOOP

ENV HADOOP_VERSION 2.7.0
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
RUN wget http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar -vxzf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/hadoop-$HADOOP_VERSION && \
    rm -rf $HADOOP_HOME/share/doc

# SPARK

ENV SPARK_VERSION 2.4.0
ENV SPARK_PACKAGE spark-$SPARK_VERSION-bin-without-hadoop
ENV SPARK_HOME /usr/spark-$SPARK_VERSION
ENV PYSPARK_DRIVER_PYTHON ipython
ENV PYSPARK_PYTHON python3
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin
RUN wget https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-without-hadoop.tgz && \
    tar -xvzf spark-2.4.0-bin-without-hadoop.tgz && \
    mv $SPARK_PACKAGE $SPARK_HOME && \
    rm -rf $SPARK_HOME/examples $SPARK_HOME/ec2

## install ripgrep
RUN wget https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb \
    && dpkg -i ripgrep_0.10.0_amd64.deb
RUN apt-get clean
RUN ln -sf /bin/bash /bin/sh
RUN ln -s /bin/sh /usr/local/bin/sh

# user details
ENV USER=user
ENV UID=1000
ENV GID=1000

# create user
RUN groupadd --gid $GID $USER
RUN useradd --create-home --shell /bin/sh --uid $UID --gid $GID $USER
RUN echo 'user ALL=(ALL)   NOPASSWD:ALL' >> /etc/sudoers
USER $USER
WORKDIR /$SPARK_HOME
RUN echo 'export JAVA_HOME=$(dirname $(dirname $(readlink -f  /usr/bin/java)))' >> /home/$USER/.bashrc
RUN echo 'export JAVA_HOME=$(readlink -f /usr/bin/javac | sed "s:/bin/javac::")' >> /home/$USER/.bashrc
RUN /bin/bash -c "source /home/$USER/.bashrc"

CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]
