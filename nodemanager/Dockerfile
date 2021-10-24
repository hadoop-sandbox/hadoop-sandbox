FROM --platform=linux/amd64 ${DOCKER_ORG:-packet}/${DOCKER_PREFIX:-}base:${DOCKER_HADOOP_VERSION:-local}
USER yarn
WORKDIR /home/yarn
CMD ["/opt/hadoop/bin/yarn", "nodemanager"]
