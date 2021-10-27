#!/usr/bin/env bash
set -Eeo pipefail

gosu hdfs hdfs dfs -mkdir -p /user/sandbox
gosu hdfs hdfs dfs -chown sandbox:sandbox /user/sandbox
