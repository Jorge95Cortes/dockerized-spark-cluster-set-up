# Create overlay network if it doesn't exist
docker network create --driver overlay spark-c-net

# Create master service
docker service create \
  --name spark-master \
  --network spark-c-net \
  --constraint 'node.labels.spark-role == master' \
  --publish published=8080,target=8080 \
  --publish published=7077,target=7077 \
  --env SPARK_LOCAL_IP=0.0.0.0 \
  --env SPARK_MASTER_HOST=spark-master \
  --env SPARK_MASTER_BIND_ADDRESS=0.0.0.0 \
  --env SPARK_MASTER_WEBUI_PORT=8080 \
  --env SPARK_DRIVER_HOST=spark-master \
  --env SPARK_MASTER_OPTS="-Dspark.ui.port=8080" \
  --replicas 1 \
  --with-registry-auth \
  spark:latest \
  /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master -h 0.0.0.0

# Create worker service
docker service create \
  --name spark-worker \
  --network spark-c-net \
  --constraint 'node.labels.spark-role == worker' \
  --publish published=8081,target=8081 \
  --env SPARK_MASTER=spark://192.168.3.48:7077 \
  --env SPARK_WORKER_WEBUI_PORT=8081 \
  --env SPARK_LOCAL_IP=0.0.0.0 \
  --env SPARK_PUBLIC_DNS=spark-worker \
  --replicas 1 \
  spark:latest \
  /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://192.168.3.48:7077

docker exec -it f11a10afb969 /opt/spark/bin/spark-submit \
  --master spark://192.168.3.48:7077 \
  --conf spark.driver.host=192.168.3.48 \
  --conf spark.driver.bindAddress=0.0.0.0 \
  --conf spark.network.timeout=120s \
  --class org.apache.spark.examples.SparkPi \
  /opt/spark/examples/jars/spark-examples_2.12-3.5.5.jar 100

docker service create \
  --name spark-master \
  --network spark-c-net \
  --publish 8080:8080 \
  --publish 7077:7077 \
  --env SPARK_MODE=master \
  bitnami/spark:latest

docker service create \
  --name spark-worker \
  --network spark-c-net \
  --publish 8081:8081 \
  --env SPARK_MODE=worker \
  --env SPARK_MASTER_URL=spark://spark-master:7077 \
  --replicas 3 \
  bitnami/spark:latest