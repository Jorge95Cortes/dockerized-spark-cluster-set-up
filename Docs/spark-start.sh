#!/bin/bash
# spark-start.sh

CONTAINER_IP=$(hostname -i)
echo "Container IP: $CONTAINER_IP"

# Start Spark shell with proper networking
exec spark-shell --master spark://spark-master:7077 \
  --conf "spark.driver.host=$CONTAINER_IP" \
  --conf "spark.driver.bindAddress=0.0.0.0" \
  --conf "spark.executor.memory=1g" \
  --conf "spark.network.timeout=600s"