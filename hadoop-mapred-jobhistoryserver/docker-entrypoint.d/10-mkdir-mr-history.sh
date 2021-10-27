#!/usr/bin/env bash
set -Eeo pipefail
gosu hdfs hdfs dfs -mkdir -p /mr-history
gosu hdfs hdfs dfs -mkdir -p /tmp
gosu hdfs hdfs dfs -chmod 1777 /tmp
gosu hdfs hdfs dfs -chmod 755 /mr-history
gosu hdfs hdfs dfs -chown mapred:hadoop /mr-history
