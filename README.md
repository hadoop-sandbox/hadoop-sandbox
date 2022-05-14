# Hadoop Sandbox

A Hadoop Yarn cluster running in a docker-compose deployment.

## Docker images

The deployment uses the docker images created by
[hadoop-sandbox-images](https://github.com/hadoop-sandbox/hadoop-sandbox-images).

## How to run

:warning: Running the cluster requires docker-compose 1.27 or
newer. The version in Ubuntu 20.04 LTS is too old, but newer versions
can be installed using pip.

```bash
docker-compose up
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

To enable password-less access to the client node, you can setup SSH
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

To login to client node, you can then use
```bash
ssh yarn
```

## Smoke test

:warning: The following steps will need to store data on
disk. When running on macOS, you should ensure that Docker's *Disk
image size* is set to a capacity that can hold the dataset (9.3 GiB in
the example) at least 3 times.

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

The example uses Python and [pywebhdfs](https://pypi.org/project/pywebhdfs/). To setup, create a venv and install
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
curl -fsSLo async-profiler.tar.gz https://github.com/jvm-profiling-tools/async-profiler/releases/download/v2.8/async-profiler-2.8-linux-x64.tar.gz
echo "f3a52b167cfd59f740383c57cd9c6da5b0b4d8b0efb7d01510b2af1e0cd5472e *async-profiler.tar.gz" | sha256sum -c -
tar -xzf async-profiler.tar.gz
```

This command line then renders flame graphs of terasort as a separate log file for each Yarn container:
```shell
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  terasort \
  -files async-profiler-2.8-linux-x64/build/libasyncProfiler.so \
  -D '"mapred.child.java.opts=-agentpath:libasyncProfiler.so=start,event=cpu,simple,title=@taskid@,file=$(dirname $STDOUT_LOGFILE_ENV)/@taskid@.html,log=$(dirname $STDOUT_LOGFILE_ENV)/@taskid@-profiler.log"' \
  /user/sandbox/teragen /user/sandbox/terasort
```
