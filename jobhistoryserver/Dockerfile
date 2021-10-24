FROM --platform=linux/amd64 ${DOCKER_ORG:-packet}/${DOCKER_PREFIX:-}base:${DOCKER_HADOOP_VERSION:-local}
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["gosu", "mapred", "/opt/hadoop/bin/mapred", "historyserver"]
