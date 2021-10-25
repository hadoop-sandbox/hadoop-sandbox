FROM --platform=linux/amd64 ${DOCKER_ORG:-packet23}/${DOCKER_PREFIX:-}hadoop-common:${DOCKER_HADOOP_VERSION:-local}
USER hdfs
WORKDIR /home/hdfs
COPY --chown=root:root docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["/opt/hadoop/bin/hdfs", "namenode"]
