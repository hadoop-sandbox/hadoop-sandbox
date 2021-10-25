FROM --platform=linux/amd64 ${DOCKER_ORG:-packet23}/${DOCKER_PREFIX:-}hadoop-common:${DOCKER_HADOOP_VERSION:-local}
USER yarn
WORKDIR /home/yarn
CMD ["/opt/hadoop/bin/yarn", "nodemanager"]
