FROM --platform=linux/amd64 ${DOCKER_ORG:-packet}/${DOCKER_PREFIX:-}base:${DOCKER_HADOOP_VERSION:-local}
USER hdfs
WORKDIR /home/hdfs
COPY --chown=root:root docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["/opt/hadoop/bin/hdfs", "namenode"]
