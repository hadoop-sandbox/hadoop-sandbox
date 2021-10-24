#! /bin/bash

set -e

gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -mkdir -p /user/user
gosu hdfs "${HADOOP_HOME}/bin/hdfs" dfs -chown user:user /user/user

exec "$@"
