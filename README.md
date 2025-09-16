# Hadoop Sandbox

A Hadoop Yarn cluster running in a docker compose deployment.


## Docker images

The deployment uses the docker images created from
* [hadoop-sandbox-images](https://github.com/hadoop-sandbox/hadoop-sandbox-images)
* [prometheus-jmx-exporter-images](https://github.com/hadoop-sandbox/prometheus-jmx-exporter-images)


## Prerequisites

The deployment needs Docker compose 2.x. Older versions may work but are untested.
Installation instructions for Docker compose are on
[docs.docker.com](https://docs.docker.com/compose/install/).


## How to run

```bash
docker compose up
```


## Using the cluster

A client node is running and can be accessed using SSH (username:
sandbox, password: sandbox):

```bash
ssh -p 2222 sandbox@localhost
```

The different cluster service web user interfaces can be reached over:

* [Overview page](http://localhost:8080)
* [Resource Manager](http://localhost:8088/)
* [Name Node](http://localhost:9870/)
* [Job History Server](http://localhost:19888/)
* [Data Node](http://localhost:9864/)
* [Node Manager](http://localhost:8042/)
* [WebHDFS UI](http://localhost:9870/explorer.html)


## SSH setup

Always typing port and username can become quite tedious. You can
configure your SSH client with a host in `~/.ssh/config`:

```
Host yarn
  Hostname localhost
  Port 2222
  User sandbox
  IdentityFile ~/.ssh/yarn
  IdentitiesOnly yes
```

To enable password-less access to the client node, you can set up SSH
keys.

```bash
ssh-keygen -f ~/.ssh/yarn
```

will create a key pair on your local machine. The key should be added
to your local `ssh-agent`:

```bash
ssh-add -f ~/.ssh/yarn
```

The key has to be installed in the client node:

```bash
ssh-copy-id -i ~/.ssh/yarn.pub yarn
```

To log in to client node, you can then use
```bash
ssh yarn
```


## Deployment settings

These configuration variables can be customized via an `.env` file:

| Variable name            | Default value                                                  | Description                                          |
|--------------------------|----------------------------------------------------------------|------------------------------------------------------|
| `NAMENODE_IMAGE`         | `ghcr.io/hadoop-sandbox/hadoop-hdfs-namenode:latest`           | Container image for the HDFS Namenode                |
| `DATANODE_IMAGE`         | `ghcr.io/hadoop-sandbox/hadoop-hdfs-datanode:latest`           | Container image for the HDFS Datanode                |
| `RESOURCEMANAGER_IMAGE`  | `ghcr.io/hadoop-sandbox/hadoop-yarn-resourcemanager:latest`    | Container image for the YARN Resource manager        |
| `NODEMANAGER_IMAGE`      | `ghcr.io/hadoop-sandbox/hadoop-yarn-nodemanager:latest`        | Container image for the YARN Node manager            |
| `JOBHISTORYSERVER_IMAGE` | `ghcr.io/hadoop-sandbox/hadoop-mapred-jobhistoryserver:latest` | Container image for the MapReduce Job history server |
| `CLIENT_IMAGE`           | `ghcr.io/hadoop-sandbox/hadoop-client:latest`                  | Container image for the client node                  |
| `JMX_EXPORTER_IMAGE`     | `ghcr.io/hadoop-sandbox/prometheus-jmx-exporter:latest`        | Container image for the JMX exporter                 |
| `HTTPD_IMAGE`            | `httpd:2.4`                                                    | Container image for the Apache Httpd front           |
| `LISTEN_ADDRESS`         | `127.0.0.1`                                                    | Address to expose ports on host machine              |
| `LISTEN_HOST`            | `localhost`                                                    | Hostname pointing to listen address                  |


## Smoke test

> [!WARNING]
> The following steps will need to store data on
> disk. When running the container runtime in a virtual machine
> (i.e. Docker for mac, Rancher-Desktop), you should ensure that
> the container runtime has enough storage capacity to store the
> test dataset (9.3 GiB) at least 3 times.

Start the cluster and log on to client node (see above). You can run
Teragen/Terasort/Teravalidate to see if the cluster is able to run
Hadoop MapReduce jobs and read/write to HDFS. To generate a 9.3 GiB
dataset you would use:

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
   teragen 100000000 /user/sandbox/teragen
```

Teragen generates test data to be sorted by Terasort. To sort the
generated dataset, you would use

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
   terasort /user/sandbox/teragen /user/sandbox/terasort
```

Terasort sorts the generated dataset and outputs the same dataset
globally sorted. Teravalidate verifies that the dataset is globally
sorted. You can run it like this:

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
   teravalidate /user/sandbox/terasort /user/sandbox/teravalidate
```


## Native code smoke test

Loading of native code dependencies can be verified on the client node
as well. To check, issue the following command:

```bash
hadoop checknative
```

The output should look like this:

```
2021-10-25 19:31:48,186 INFO bzip2.Bzip2Factory: Successfully loaded & initialized native-bzip2 library system-native
2021-10-25 19:31:48,187 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
2021-10-25 19:31:48,207 INFO nativeio.NativeIO: The native code was built without PMDK support.
Native library checking:
hadoop:  true /hadoop/lib/native/libhadoop.so.1.0.0
zlib:    true /lib/x86_64-linux-gnu/libz.so.1
zstd  :  true /lib/x86_64-linux-gnu/libzstd.so.1
bzip2:   true /lib/x86_64-linux-gnu/libbz2.so.1
openssl: true /lib/x86_64-linux-gnu/libcrypto.so
ISA-L:   true /lib/x86_64-linux-gnu/libisal.so.2
PMDK:    false The native code was built without PMDK support.
```


## Accessing Hdfs from Host via WebHDFS

The example uses Python and [pywebhdfs](https://pypi.org/project/pywebhdfs/). To set up, create a venv and install
pywebhdfs:

```bash
python -m venv .venv && \
   . .venv/bin/activate && \
   python -m pip install pywebhdfs
```

Then you should be able to list the directory contents of the sandbox user home:

```python
from pywebhdfs.webhdfs import PyWebHdfsClient
client = PyWebHdfsClient(host="localhost", port=9870, user_name="sandbox")
listing = client.list_dir("/user/sandbox")
print(listing)
```


## Profiling using Async Profiler

Yarn applications can be profiled using the
[async-profiler](https://github.com/jvm-profiling-tools/async-profiler/releases). First fetch a release tarball
of async-profiler and unpack on the client node (assuming your host is x86-64):
```bash
curl -fsSLo async-profiler.tgz 'https://github.com/jvm-profiling-tools/async-profiler/releases/download/v2.9/async-profiler-2.9-linux-x64.tar.gz'
sha256sum -c <<<"b9a094bc480f233f72141b7793c098800054438e0e6cfe5b7f2fe13ef4ad11f0 *async-profiler.tgz"
tar -xzf async-profiler.tgz --strip-components=1 --one-top-level=async-profiler
```

This command line then renders flame graphs of terasort as a separate log file for each Yarn container:
```shell
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  terasort \
  -files async-profiler/build/libasyncProfiler.so \
  -D '"mapred.child.java.opts=-agentpath:libasyncProfiler.so=start,event=cpu,simple,title=@taskid@,file=$(dirname $STDOUT_LOGFILE_ENV)/@taskid@.html,log=$(dirname $STDOUT_LOGFILE_ENV)/@taskid@-profiler.log"' \
  /user/sandbox/teragen /user/sandbox/terasort
```


## Exposing to the network

> [!WARNING]
> Exposing the cluster is not recommended and should only be done in private networks.

By default, the cluster is reachable only from host machine. There are two variables that can be defined to
make it reachable over the network as well:

* `LISTEN_ADDRESS` - the IP address on which SSH and the different WebUI are listening for requests
* `LISTEN_HOST` - the host name under which SSH and the WebUI can be reached

If for instance `myhostname.example` resolves to the IP address of the host, the following `.env` file
will configure the cluster to be exposed under this name and listen on all addresses of the host:

```shell
LISTEN_ADDRESS="0.0.0.0"
LISTEN_HOST="myhostname.example"
```


## Breaking changes

### 2024-04-01 - Hadoop 3.4.0

Configuration has been adapted for Hadoop 3.4.0. New configuration is
not tested against old Hadoop 3.3.x container images. When pulling the
new config, make sure to pull the new images as well using

```bash
docker compose pull
docker compose down
docker compose up
```


### 2022-08-19 - Init

PID 1 now runs an injected `docker-init` binary via `init: true` in
the `docker-compose.yaml`. Previously, `tini` was included in the docker images.
If you pulled the old images you will see

```
[WARN  tini (7)] Tini is not running as PID 1 and isn't registered as a child subreaper.
```

in logs. This is harmless and can easily be corrected by pulling latest images using

```bash
docker compose pull
docker compose down
docker compose up
```


### 2022-08-18 - Docker Volumes

Writable volume mounts have been changed from `bind` to the default driver for
docker volumes.

That means:

* previously created data stored in the `data/` subfolder will not be
accessible by the hadoop-sandbox docker compose deployment
* that includes data stored on HDFS, and data stored in home folder of
`sandbox` user
* additionally, SSH host keys will be regenerated

For users that have been using the deployment before 2022-08-18 there are
two alternatives for migration:

* Migration of old data or
* Remove old data

Both alternatives are described below. You do not need to do anything
unless you used the deployment before 2022-08-18.


#### Migration of old data

If you used an older version of this deployment and would like to retain the data,
you can follow these steps to transfer to the new deployment:

1. Start the old deployment
2. Copy HDFS data to local filesystem `ssh -p 2222 sandbox@localhost hdfs dfs -copyToLocal /user/sandbox hdfs-data`
3. Copy sandbox user's home dir to host: `ssh -p 2222 sandbox@localhost tar -cf - . > sandbox.tar`
4. Stop the old deployment
5. Update the deployment via `git pull`
6. Start the new deployment
7. Clear SSH's `known_hosts` file via `ssh-keygen -R '[localhost]:2222'`
8. Update your `known_hosts` file via `ssh -p 2222 sandbox@localhost true`
9. Upload old data via SSH: `ssh -p 2222 sandbox@localhost tar -xf - < sandbox.tar`
10. Upload old HDFS data to HDFS via `ssh -p 2222 sandbox@localhost hdfs dfs -copyFromLocal hdfs-data /user/sandbox`
11. Remove local copy on `clientnode` via `ssh -p 2222 sandbox@localhost rm -rf hdfs-data`
12. Remove backup on host via `rm sandbox.tar`
13. Remove old `bind` mounted data stored under `data/` subfolder on the host (might require `sudo`)


#### Remove old data

If you used an older version of this deployment and would like to start from scratch,
you can follow these steps to remove old data:

1. Update the deployment via `git pull`
2. Start the deployment
3. Clear SSH's `known_hosts` file via `ssh-keygen -R '[localhost]:2222'`
4. Update your `known_hosts` file via `ssh -p 2222 sandbox@localhost true`
5. Install your SSH key via `ssh-copy-id -i ~/.ssh/yarn.pub -p 2222 sandbox@localhost`
6. Remove old `bind` mounted data stored under `data/` subfolder on the host (might require `sudo`)
