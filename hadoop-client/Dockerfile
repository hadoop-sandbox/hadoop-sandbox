FROM --platform=linux/amd64 ${DOCKER_ORG:-packet23}/${DOCKER_PREFIX:-}hadoop-common:${DOCKER_HADOOP_VERSION:-local}
COPY ./docker-entrypoint.d /docker-entrypoint.d
RUN  apt-get update && \
   DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-upgrade --no-install-recommends openssh-server && \
   rm -rf /var/lib/apt/lists/* && \
   install -d -o root -g root -m 755 /run/sshd && \
   rm /etc/ssh/ssh_host_*_key /etc/ssh/ssh_host_*_key.pub && \
   mv /etc/ssh /etc/ssh.in
CMD ["/usr/sbin/sshd", "-D", "-e"]

