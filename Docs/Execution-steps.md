# Connect to namenode
docker exec -it $(docker ps -q --filter name=namenode) bash

# Create a test directory
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

# Find the Spark master container ID
docker ps | grep spark-master

# Connect to the Spark master container
docker exec -it <spark-master-container-id> bash

# Inside the container
/opt/bitnami/scripts/spark-start.sh

# Start the Spark shell with HDFS configuration
spark-shell --master spark://spark-master:7077

// Read the file from HDFS
val textFile = spark.read.textFile("hdfs://namenode:9000/test/test.txt")

// Perform word count
val counts = textFile.flatMap(line => line.split(" ")).map(word => (word, 1)).groupBy("_1").count()

// Show the results
counts.show()

// Save the results back to HDFS
counts.write.csv("hdfs://namenode:9000/test/word-count-output")

// Exit Spark shell
:quit