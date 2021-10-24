FROM --platform=linux/amd64 adoptopenjdk:8-jdk-hotspot-focal AS downloader
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /tmp
RUN curl -fsSLo "hadoop.tgz" "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz" && \
  echo "SHA512 (hadoop.tgz) = 2fd0bf74852c797dc864f373ec82ffaa1e98706b309b30d1effa91ac399b477e1accc1ee74d4ccbb1db7da1c5c541b72e4a834f131a99f2814b030fbd043df66" | sha512sum -c && \
  tar -C /opt -xzf hadoop.tgz && \
  mv "/opt/hadoop-3.3.1" /opt/hadoop && \
  chown -R root:root /opt/hadoop && \
  chmod -R g-w,o-w /opt/hadoop && \
  install -d -o root -g root -m 1777 /opt/hadoop/logs && \
  rm hadoop.tgz
RUN curl -fsSLo "tini" "https://github.com/krallin/tini/releases/download/v0.19.0/tini-amd64" && \
  echo "93dcc18adc78c65a028a84799ecf8ad40c936fdfc5f2a57b1acda5a8117fa82c  tini" | sha256sum -c && \
  install -o root -g root -m 755 tini /tini && \
  rm tini
COPY ./environment /etc/environment
RUN chown root:root /etc/environment && \
  chmod 644 /etc/environment
 
FROM --platform=linux/amd64 adoptopenjdk:8-jdk-hotspot-focal
COPY --from=downloader /opt/hadoop /opt/hadoop
COPY --from=downloader /tini /tini
COPY --from=downloader /etc/environment /etc/environment
ENV HADOOP_HOME=/opt/hadoop
RUN groupadd hadoop && \ 
  useradd -ms /bin/bash user && \
  echo "user:hadoop" | chpasswd && \
  useradd -ms /bin/bash -G hadoop hdfs && \
  useradd -ms /bin/bash -G hadoop yarn && \
  useradd -ms /bin/bash -G hadoop mapred && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-upgrade --no-install-recommends libssl-dev libisal2 gosu && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/tini", "--"]
