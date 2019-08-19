FROM centos:centos7

MAINTAINER Martin Becker <martin-becker [at] t-systems.com>

ENV ZEPPELIN_VERSION 0.8.0
ENV ZEPPELIN_PORT 15000
ENV ZEPPELIN_HOME /usr/local/zeppelin
ENV SPARK_HOME /usr/local/spark
ENV HIVE_HOME /usr/local/hive
ENV SPARK_PROFILE 2.4
ENV HADOOP_PROFILE 2.7
ENV SPARK_VERSION 2.3.3
ENV HIVE_VERSION 2.3.5
ENV HADOOP_VERSION 2.7.7

# install base
RUN yum -y install \
    curl \
    wget \
    git \
    htop \
    vim \
    unzip \
    net-tools \
    openssh-server \
    openssh-clients \
    python-setuptools \
    rsync

# Update the image with the latest packages
# RUN yum update -y; yum clean all

# install supervisord
RUN easy_install supervisor

# install jdk8
RUN yum install -y java-1.8.0-openjdk-devel
ENV JAVA_HOME /usr/lib/jvm/java
ENV PATH $PATH:$JAVA_HOME/bin

# install spark 
RUN curl -s http://www.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE spark

# install hadoop
RUN curl -s http://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s hadoop-$HADOOP_VERSION hadoop

# install zeppelin
RUN curl -s http://www.apache.org/dist/zeppelin/zeppelin-$ZEPPELIN_VERSION/zeppelin-$ZEPPELIN_VERSION-bin-all.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s zeppelin-$ZEPPELIN_VERSION-bin-all zeppelin

# install hive
RUN curl -s http://www.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s hive-$HIVE_VERSION-bin-all hive

# install ssh and run through supervisor
RUN mkdir /var/run/sshd
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
RUN /usr/bin/ssh-keygen -A
RUN cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
RUN /usr/sbin/sshd && ssh-keyscan -H localhost >> /root/.ssh/known_hosts && ssh-keyscan -H 127.0.0.1 >> /root/.ssh/known_hosts

# copy hadoop configs
ADD config/root_bashrc_hadoop.source /root/.bashrc
RUN mkdir /etc/hadoop
ADD config/etc_hadoop_core-site.xml /etc/hadoop/core-site.xml
ADD config/etc_hadoop_yarn-site.xml /etc/hadoop/yarn-site.xml
ADD config/etc_hadoop_mapred-site.xml /etc/hadoop/mapred-site.xml
ADD config/etc_hadoop_hdfs-site.xml /etc/hadoop/hdfs-site.xml
ADD config/etc_hadoop_capacity-scheduler.xml /etc/hadoop/capacity-scheduler.xml
RUN mkdir -p /data/yarn/nodemanager/log /data/yarn/nodemanager/data /data/hdfs/datanode /data/hdfs/namenode
RUN mkdir -p /data/transfert

# slave management
ADD config/etc_hadoop_slaves /etc/hadoop/slaves

# copy example files
#RUN mkdir /example
#ADD example/fichier.txt /example/fichier.txt
#ADD example/mapper.py /example/mapper.py
#ADD example/reducer.py /example/reducer.py
#RUN chmod a+x /example/*.py

# configure zeppelin
RUN cp $ZEPPELIN_HOME/conf/zeppelin-env.sh.template $ZEPPELIN_HOME/conf/zeppelin-env.sh
RUN cp $ZEPPELIN_HOME/conf/shiro.ini.template $ZEPPELIN_HOME/conf/shiro.ini
RUN cat $ZEPPELIN_HOME/conf/shiro.ini | sed 's/#admin = password1, admin/admin = password1, admin/g' > $ZEPPELIN_HOME/conf/shiro.ini.tmp
RUN mv $ZEPPELIN_HOME/conf/shiro.ini.tmp $ZEPPELIN_HOME/conf/shiro.ini
RUN echo "export ZEPPELIN_PORT=$ZEPPELIN_PORT" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh
RUN echo "export ZEPPELIN_WEBSOCKET_MAX_TEXT_MESSAGE_SIZE=4096000" >> $ZEPPELIN_HOME/conf/zeppelin-env.sh

# install spark
ADD config/SPARK_HOME_conf_spark-env.sh /usr/local/spark/conf/spark-env.sh

# install hive
#RUN \
#    echo "load hive (90MB)" && wget -q -O /root/hive-bin.tar.gz http://apache.mirrors.ovh.net/ftp.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz && \
#    echo "untar file" && cd /root && tar zxf hive-bin.tar.gz && \
#    mv apache-hive-1.2.1-bin /usr/local/hive

# ADD config/zeppelin-env.sh /usr/local/zeppelin/conf/zeppelin-env.sh

# configuration of supervisord
# ADD config/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# add start script
ADD docker/start.sh /root/start.sh
RUN chmod u+x /root/start.sh

# install data
VOLUME ["/data"]

# Expose ports

# hdfs port
EXPOSE 9000
EXPOSE 8020

# namenode port
EXPOSE 50070

# Resouce Manager
EXPOSE 8032
EXPOSE 8088

# MapReduce JobHistory Server Web UI
EXPOSE 19888

# MapReduce JobHistory Server
EXPOSE 10020

# Zeppelin
EXPOSE 15000

# Cleanup of installation files
#RUN \
#  apt-get clean && \
#  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
#  rm -rf /var/cache/oracle-jdk7-installer

CMD [ "/root/start.sh" ]
#CMD [ "/bin/bash" ]
