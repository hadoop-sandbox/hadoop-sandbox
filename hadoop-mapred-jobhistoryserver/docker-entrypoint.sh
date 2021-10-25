#! /bin/bash

set -e

gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p /mr-history
gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p /tmp
gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -chmod 1777 /tmp
gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -chmod 755 /mr-history
gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -chown mapred:hadoop /mr-history

exec "$@"
