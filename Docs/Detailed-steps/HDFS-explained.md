# Hadoop and HDFS Explained

## What is Hadoop?
Hadoop is a distributed storage and processing framework that is commonly used in big data applications. It is composed of several components, including the Hadoop Distributed File System (HDFS), which is a distributed file system that stores data across multiple nodes in a cluster, that we'll be using to store the data processed by the Spark cluster.

## Hadoop Cluster Architecture
To use HDFS is necessary to set up a Hadoop cluster, which is a group of nodes running Hadoop services. The Hadoop cluster consists of:
- A master node that runs the NameNode and ResourceManager services
- One or more worker nodes that run the DataNode and NodeManager services

## Implementation Challenges
Setting up a Hadoop cluster can be complex, as it requires a lot of configuration and tuning to get it working correctly. So it took me a while to get it working, but I finally managed to set up a Hadoop cluster with a master and a worker node using Docker and connecting it to the Spark cluster.

## Current Status and Considerations
Further tests are needed to ensure that the Hadoop cluster is resilient and can handle large amounts of data, but for now, it is working correctly and can be used to store data for the Spark cluster. Also, we still need to evaluate the benefits of using HDFS over just using the local filesystem for the Spark cluster.

## Testing
For detailed steps on how to test the Hadoop cluster functionality, please refer to the [Execution Steps](Execution-steps.md) document.
