# Hadoop Sandbox

A Hadoop Yarn cluster running in a docker-compose deployment.

## Docker images

The deployment uses the docker images created by
[hadoop-sandbox-images](https://github.com/packet23/hadoop-sandbox-images).

## How to run

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


## SSH setup

Always typing port and username can become quite tedious. You can
configure your SSH client with a host in `~/.ssh/config`:

```
Host yarn
  Hostname localhost
  Port 2222
  User sandbox
  IdentityFile ~/.ssh/yarn
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
ssh-copy-id -i ~/.ssh/yarn yarn
```

To login to client node, you can then use
```bash
ssh yarn
```

## Smoke test

:warning: *WARNING:* The following steps will need to store data on
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

## Testing native code

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
