FROM --platform=linux/amd64 ${DOCKER_ORG:-packet}/${DOCKER_PREFIX:-}base:${DOCKER_HADOOP_VERSION:-local}
USER hdfs
WORKDIR /home/hdfs
CMD ["/opt/hadoop/bin/hdfs", "datanode"]
