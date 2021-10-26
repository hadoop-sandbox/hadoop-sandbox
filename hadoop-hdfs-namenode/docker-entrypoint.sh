#! /bin/bash

set -e

if ! "${HADOOP_HOME}/bin/hdfs" namenode -metadataVersion; then
   "${HADOOP_HOME}/bin/hdfs" namenode -format -nonInteractive
fi

exec "$@"
