#!/usr/bin/env bash
set -Eeo pipefail
if ! gosu hdfs hdfs namenode -metadataVersion; then
   gosu hdfs hdfs namenode -format -nonInteractive
fi

