FROM --platform=linux/amd64 ${DOCKER_ORG:-packet23}/${DOCKER_PREFIX:-}hadoop-common:${DOCKER_HADOOP_VERSION:-local}
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["gosu", "mapred", "/opt/hadoop/bin/mapred", "historyserver"]
