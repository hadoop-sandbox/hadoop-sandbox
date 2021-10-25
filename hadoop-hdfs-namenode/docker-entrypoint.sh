#! /bin/bash

set -e

"${HADOOP_HOME}/bin/hdfs" namenode -format -nonInteractive

exec "$@"
