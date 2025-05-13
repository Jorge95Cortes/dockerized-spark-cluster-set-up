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
docker exec -it $(docker ps -q --filter name=spark-master) bash
<<<<<<< HEAD

=======
>>>>>>> 22a2d8c (This commit includes an automatic labelling script, it also asign resources explicitly to each node on the cluster)

# The Spark Master daemon starts automatically when the container launches.
# You can verify its UI at http://localhost:8080 on your host machine.
# The `spark-shell` command below should be run inside the spark-master container's bash prompt.

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

<<<<<<< HEAD
=======
### Running PySpark Analysis on HDFS Data (Python)

Alternatively, you can use PySpark (Python) to perform the same analysis.

Start the PySpark shell:

```bash
# Inside the spark-master container, start the PySpark shell
pyspark --master spark://spark-master:7077
```

In the PySpark shell, run the word count example:

```python
# Read the file from HDFS
# Note: .rdd.map(lambda r: r[0]) is used to convert DataFrame rows to simple strings
textFile = spark.read.text("hdfs://namenode:9000/test/test.txt").rdd.map(lambda r: r[0])

# Perform word count
counts = textFile.flatMap(lambda line: line.split(" ")) \\
                 .map(lambda word: (word, 1)) \\
                 .reduceByKey(lambda a, b: a + b)

# Show the results
# Convert RDD to DataFrame for prettier output
counts_df = counts.toDF(["word", "count"])
counts_df.show()

# Save the results back to HDFS
counts_df.write.csv("hdfs://namenode:9000/test/pyspark-word-count-output")

# Exit PySpark shell
# exit()
```

You can view the results by going back to the namenode container and checking the output directory:

```bash
# In the namenode container
hdfs dfs -ls /test/pyspark-word-count-output
hdfs dfs -cat /test/pyspark-word-count-output/part-*.csv
```

>>>>>>> 22a2d8c (This commit includes an automatic labelling script, it also asign resources explicitly to each node on the cluster)
## Aditional tests

```bash
# In case that jupyter fails miserably, temporal solution
docker cp "file_route" $(docker ps -q --filter name=namenode):/tmp/ibm_card_txn.csv
docker exec -it $(docker ps -q --filter name=namenode) bash
hdfs dfs -mkdir -p /user/jovyan
hdfs dfs -put /tmp/ibm_card_txn.csv /user/jovyan/ibm_card_txn.csv
hdfs dfs -ls /user/jovyan
docker exec -it $(docker ps -q --filter name=jupyter-notebook) bash
ls /usr/local/
# Look for a spark directory
exit
```

```bash
# On your host machine (not inside a container)
NAMENODE_CONTAINER_ID=$(docker ps -q --filter name=namenode)
docker cp /home/grecal/Documents/PPC/Spark-Project/dockerized-spark-cluster-set-up/Docs/Data_files $NAMENODE_CONTAINER_ID:/tmp/ibm_card_tnx_data
# On your host machine
docker exec -it $NAMENODE_CONTAINER_ID bash
# Inside the namenode container's shell
hdfs dfs -mkdir -p hdfs://namenode:9000/test_bd
hdfs dfs -put /tmp/ibm_card_tnx_data/* hdfs://namenode:9000/test_bd/
# Inside the namenode container's shell
hdfs dfs -ls hdfs://namenode:9000/test_bd/
exit

docker ps | grep spark-master
# On your host machine
docker cp /home/grecal/Documents/PPC/Spark-Project/dockerized-spark-cluster-set-up/Docs/Test_scripts/test.py spark-master:/tmp/test.py
# Connect to the Spark master container
docker exec -it spark-master bash

# Inside the container, run the script
<<<<<<< HEAD
spark-submit /tmp/test.py
=======
spark-submit /tmp/test.py
```
>>>>>>> 22a2d8c (This commit includes an automatic labelling script, it also asign resources explicitly to each node on the cluster)
