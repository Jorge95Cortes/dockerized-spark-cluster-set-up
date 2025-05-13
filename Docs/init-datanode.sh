#!/bin/bash

# Wait for NameNode to be available
# This is a simple check; a more robust solution might involve checking HDFS status
MAX_WAIT_NAMENODE=60 # Increased wait time for namenode
COUNT_NAMENODE=0
NAMENODE_HOST="namenode" # Service name from docker-compose
NAMENODE_PORT="9870"

echo "Waiting for NameNode ($NAMENODE_HOST:$NAMENODE_PORT) to be up..."
while ! curl -sf http://$NAMENODE_HOST:$NAMENODE_PORT ; do 
    sleep 10
    COUNT_NAMENODE=$((COUNT_NAMENODE+10))
    if [ $COUNT_NAMENODE -ge $MAX_WAIT_NAMENODE ]; then
        echo "NameNode did not become available within $MAX_WAIT_NAMENODE seconds. Exiting."
        exit 1
    fi
    echo "Still waiting for NameNode... ($COUNT_NAMENODE/$MAX_WAIT_NAMENODE)"
done
echo "NameNode is up! Proceeding to start DataNode."

# Remove existing data
rm -rf /opt/hadoop/data/dataNode/*

# Set ownership and permissions
chown -R hadoop:hadoop /opt/hadoop/data/dataNode
chmod 755 /opt/hadoop/data/dataNode

# Start DataNode daemon
echo "Starting DataNode daemon for profile: $NODE_PROFILE on $NODE_HOSTNAME..."
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

# Keep container alive
tail -f $HADOOP_HOME/logs/*datanode*.log