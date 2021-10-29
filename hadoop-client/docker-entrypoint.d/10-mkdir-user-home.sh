#!/usr/bin/env bash
set -Eeo pipefail

install -d -o sandbox -g sandbox 755 /home/sandbox
gosu hdfs hdfs dfs -mkdir -p /user/sandbox
gosu hdfs hdfs dfs -chown sandbox:sandbox /user/sandbox
