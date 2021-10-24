FROM --platform=linux/amd64 ${DOCKER_ORG:-packet}/${DOCKER_PREFIX:-}base:${DOCKER_HADOOP_VERSION:-local}
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chown root:root /docker-entrypoint.sh && \
   chmod 755 /docker-entrypoint.sh && \
   apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-upgrade --no-install-recommends openssh-server && \
   rm -rf /var/lib/apt/lists/* && \
   install -d -o root -g root -m 755 /run/sshd
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]

