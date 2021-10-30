FROM --platform=linux/amd64 ${DOCKER_ORG:-packet23}/${DOCKER_PREFIX:-}hadoop-base:${DOCKER_HADOOP_VERSION:-local}
CMD ["gosu", "yarn", "yarn", "nodemanager"]
