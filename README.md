# docker-yarn-cluster

A Hadoop Yarn cluster running in a docker-compose deployment.

## How to build

```bash
docker-compose -f build.yaml build
```

## How to run

```bash
docker-compose up
```

## WebUIs

When the cluster is up and running, the following Web UIs can be accessed:

* [Resource Manager](http://localhost:8088/cluster)
* [Name Node](http://localhost:9870/dfshealth.html#tab-overview)
* [Job History Server](http://localhost:19888/jobhistory)
* [Data Node](http://localhost:9864/datanode.html)
* [Node Manager](http://localhost:8042/node)

## Using the cluster

A client node is running and can be accessed using SSH (username: sandbox, password: sandbox):

```bash
ssh ssh://sandbox@localhost:2222/
```

## Smoke test

Start the cluster and log on to client node (see above). You can run Teragen/Terasort/Teravalidate to see if the cluster is able to
run Hadoop MapReduce jobs and read/write to HDFS. To generate a 9.3 GiB dataset you would use:

```bash
hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
   teragen 100000000 /user/sandbox/teragen
```

Teragen generates test data to be sorted by Terasort. To sort the generated dataset, you would use

```bash
hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
   terasort /user/sandbox/teragen /user/sandbox/terasort
```

Terasort sorts the generated dataset and outputs the same dataset globally sorted. Teravalidate verifies that the dataset is
globally sorted. You can run it like this:

```bash
hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
   teravalidate /user/sandbox/terasort /user/sandbox/teravalidate
```

:warning: *WARNING*: The data is stored on HDFS and could be spilled to disk. When running on macOS, you should ensure that Docker's *Disk image size*
is set to a capacity that can hold the dataset at least 3 times.

## Testing native code

Loading of native code dependencies can be verified on the client node as well. To check, issue the following command:

```bash
hadoop checknative
```

The output should look like this:

```
2021-10-25 19:31:48,186 INFO bzip2.Bzip2Factory: Successfully loaded & initialized native-bzip2 library system-native
2021-10-25 19:31:48,187 INFO zlib.ZlibFactory: Successfully loaded & initialized native-zlib library
2021-10-25 19:31:48,207 INFO nativeio.NativeIO: The native code was built without PMDK support.
Native library checking:
hadoop:  true /opt/hadoop/lib/native/libhadoop.so.1.0.0
zlib:    true /lib/x86_64-linux-gnu/libz.so.1
zstd  :  true /lib/x86_64-linux-gnu/libzstd.so.1
bzip2:   true /lib/x86_64-linux-gnu/libbz2.so.1
openssl: true /lib/x86_64-linux-gnu/libcrypto.so
ISA-L:   true /lib/x86_64-linux-gnu/libisal.so.2
PMDK:    false The native code was built without PMDK support.
```
