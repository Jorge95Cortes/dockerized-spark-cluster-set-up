# Spark-Hadoop Cluster Execution Steps

This guide provides step-by-step instructions for working with the Spark-Hadoop cluster, from initial setup to running a word count example.

## Initial Setup

Before deploying the stack, prepare the worker nodes:

```bash
# Run on each worker node (nodes with h-role=worker label)
sudo mkdir -p /data/hadoop
sudo chmod 777 /data/hadoop
```

## Working with HDFS

### Accessing the Namenode

```bash
# Connect to namenode container
docker exec -it $(docker ps -q --filter name=namenode) bash
```

### Creating and Uploading Test Data

```bash
# Create a test directory in HDFS
hdfs dfs -mkdir -p /test

# Create a sample text file
echo "Hello Hadoop World
This is a test file
with multiple lines
for word counting
Hadoop Spark integration test" > test.txt

# Upload the file to HDFS
hdfs dfs -put test.txt /test/

# Verify the file exists
hdfs dfs -ls /test/
hdfs dfs -cat /test/test.txt
```

## Working with Spark

### Accessing the Spark Master

```bash
# Find the Spark master container ID
docker ps | grep spark-master

# Connect to the Spark master container
docker exec -it <spark-master-container-id> bash

# Inside the container, ensure Spark is running
/opt/bitnami/scripts/spark-start.sh
```

### Running Spark Analysis on HDFS Data

Start the Spark shell:

```bash
# Start the Spark shell with HDFS configuration
spark-shell --master spark://spark-master:7077
```

In the Spark shell, run the word count example:

```scala
// Read the file from HDFS
val textFile = spark.read.textFile("hdfs://namenode:9000/test/test.txt")

// Perform word count
val counts = textFile.flatMap(line => line.split(" "))
                     .map(word => (word, 1))
                     .groupBy("_1")
                     .count()

// Show the results
counts.show()

// Save the results back to HDFS
counts.write.csv("hdfs://namenode:9000/test/word-count-output")

// Exit Spark shell
:quit
```

You can view the results by going back to the namenode container and checking the output directory:

```bash
# In the namenode container
hdfs dfs -ls /test/word-count-output
hdfs dfs -cat /test/word-count-output/part-*.csv
```
```bash
# In case that jupyter fails miserably, temporal solution
docker cp "file_route" $(docker ps -q --filter name=namenode):/tmp/ibm_card_txn.csv
docker exec -it $(docker ps -q --filter name=namenode) bash
hdfs dfs -mkdir -p /user/jovyan
hdfs dfs -put /tmp/ibm_card_txn.csv /user/jovyan/ibm_card_txn.csv
hdfs dfs -ls /user/jovyan
hdfs dfs -cat /user/jovyan/ibm_card_txn.csv | head
