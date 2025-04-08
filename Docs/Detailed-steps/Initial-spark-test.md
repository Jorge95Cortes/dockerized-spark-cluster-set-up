# Initial Spark Testing

This document covers the initial testing of a Spark cluster using Docker containers. We'll go through pulling the Spark image, creating containers for the master and worker nodes, and running a simple Spark application.

## Pulling the Spark Image

First, we need to create a container with the Spark image. To do this, is necessary to pull the image from the Docker Hub. There are different versions of the image, such as Spark, Apache/Spark, and Bitnami/Spark as the most popular ones.

```bash
docker pull spark:latest
```

## Network Mode

This test is using the host network mode, which means that the container will use the host network interface. This is very likely to change in the future, but for now, it is a simple way to test the Spark container with two virtual machines running on the same host, one with Debian and the other with LUbuntu, and the host network mode allows the containers to communicate with each other without any additional configuration.

## Creating the Master and Worker Containers

We're going to create two containers, one for the master and one for the worker.

### Master Container

The master container will be created with the following command:

```bash
docker run -d   --name spark-master   --network=host -e SPARK_MASTER_HOST=<master-ip>   -e SPARK_MASTER_WEBUI_HOST=0.0.0.0   spark:latest   /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master
```

In this command, you need to replace `<master-ip>` with the IP address of your computer without the brackets. You have several ways to find the IP address of your computer, but one that doesn't require any additional software is to run the following command in the terminal:

```bash
ip route
```

This command will return the IP address of the computer in the `src` field of the output.
Here is an example of the output:
![IP Route](../assets/Ip-route-output.png)

After running the command, you can access the Spark UI by going to `http://<master-ip>:8080` in your browser. You should see the Spark master UI with no workers connected.
It might look like this:
![Spark Master UI](../assets/Spark-master-web-UI.png)

### Worker Container

The worker container will be created with the following command:

```bash
docker run -d   --name spark-worker   -p 8081:8081   -e SPARK_WORKER_WEBUI_HOST=0.0.0.0   -e SPARK_LOCAL_IP=0.0.0.0   spark:latest   /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://<master-ip>:7077
```

Again, replace `<master-ip>` with the IP address of the master computer. After this container is running, you should see the worker connected to the master in the Spark UI.
It might look like this:
![Spark Worker UI](../assets/Spark-worker-connected.png)

## Running a Simple Spark Application

We're going to run a simple Spark application to test the cluster. This application is already included in the Spark image and can be run with the following command:

```bash
docker exec spark-master   /opt/spark/bin/spark-submit   --master spark://<master-ip>:7077   --conf spark.driver.host=192.168.3.48   --class org.apache.spark.examples.SparkPi   /opt/spark/examples/jars/spark-examples_2.12-3.5.4.jar 100
```

This command will run the SparkPi example application, which calculates an approximation of Pi using the Monte Carlo method. The number `100` at the end of the command is the number of iterations the application will run. You can change this number to increase or decrease the accuracy of the approximation.

After running the command, you should see the output of the application in the terminal. It will show the value of Pi calculated by the application.
The final result might look like this:
![Spark Pi Result](../assets/SparkPi-testrun.png)

Also, you will notice that the Spark UI will show the application in the "Completed Applications" section, or in the "Running Applications" section if the application is still running.
It might look like this:
![Spark Pi Application](../assets/Completed-app-web-UI.png)
