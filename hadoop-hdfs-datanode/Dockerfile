FROM --platform=linux/amd64 ${DOCKER_ORG:-packet23}/${DOCKER_PREFIX:-}hadoop-common:${DOCKER_HADOOP_VERSION:-local}
USER hdfs
WORKDIR /home/hdfs
CMD ["/opt/hadoop/bin/hdfs", "datanode"]
