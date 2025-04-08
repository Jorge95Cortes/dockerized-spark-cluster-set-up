# Target
In this repo, I'll cover some of the steps I took to set up a Spark cluster with up to 20 nodes using Docker. This documentation covers everything from installing the required software to making network adjustments and includes tests and reports along the way.

If you are only interested on the steps to set up the cluster, you can skip the first sections and go directly to the [Cluster Deployment](#cluster-deployment) section.

# Software Installation
## Docker
To install Docker on Debian, you can see the official documentation [here](https://docs.docker.com/engine/install/debian/). Based on my experience, I recommend using docker desktop as it is more intuitive and user-friendly, but you can just install the docker engine if you prefer or have limited resources, also this is what you'll likely found on real work environments.

For detailed installation steps, please refer to the [Commands Breakdown](Docs/commands_breakdown.md#docker-installation) document.

# Initial Containers test
To test the Docker installation, you can run the following command:
```bash
docker run hello-world
```
If everything is working correctly, you should see a message saying that the installation was successful.

# Spark
For setting up Spark with Docker, we'll use Docker containers to create a master and worker nodes. For detailed instructions on how to pull the Spark image and run initial tests, see the [Initial Spark Test](Docs/Detailed-steps/Initial-spark-test.md) documentation.

Up to this point, we have a working Spark cluster with a master and a worker node running on Docker containers. The next step is to scale the cluster to include more worker nodes and test the performance of the cluster with larger datasets and more complex applications.

# Docker Swarm
Docker Swarm is a container orchestration tool that allows you to manage a cluster of Docker nodes across multiple machines, as Docker Networks are limited to multiple containers on the same host, but we're looking to multiple containers on multiple hosts.

For detailed instructions on how to set up a Docker Swarm, create overlay networks, and label nodes, please see the [Swarm Explained](Docs/Detailed-steps/Swarm-explained.md) document.

## Docker Compose
To deploy services easily in the Docker Swarm, we can use Docker Compose. Docker Compose is a tool that allows you to define and run multi-container Docker applications using a YAML file. 

To use Docker Compose, you need to create a `docker-compose.yml` file in the directory where you want to deploy the services. The file should contain the configurations for the services you want to deploy.

For detailed commands on working with Docker Compose and Swarm, refer to the [Commands Breakdown](Docs/commands_breakdown.md#docker-composestack-commands) document.

# Hadoop
Hadoop is a distributed storage and processing framework commonly used in big data applications. For detailed information about Hadoop and HDFS on this project, see the [HDFS Explained](Docs/Detailed-steps/HDFS-explained.md) document.

# Cluster deployment

The details of the cluster implementation are at the [Compose](Docs/docker-compose.yml) file, which is the file we'll use to deploy the services in the Docker Swarm.

You also need to get the scripts of Hadoop and Spark from the [Docs](Docs) folder, the files that you require are:

- `init-datanode.sh`: This script is used to initialize the DataNode container and configure it to connect to the NameNode.
- `start-hdfs.sh`: This script is used to start the HDFS services on the master and worker nodes.
- `spark-start.sh`: This script is used to start the Spark services on the master and worker nodes.
- `docker-compose.yml`: This file contains the configurations for the services, including the Hadoop master and worker nodes, as well as the Spark master and worker nodes.
- `hadoop-config/`: This folder contains the Hadoop configuration files, including `core-site.xml` and `hdfs-site.xml`, which are used to configure the Hadoop cluster.

After including the Hadoop cluster in the Docker Swarm, we can deploy the services using Docker Compose. 

In order to deploy the services, if you have not cloned the repository yet, clone it to avoid copying the files manually

You will need to navigate to the directory where the cloned repository is located and move to the `Docs` folder.

## Software Requirements

To run the Spark-Hadoop cluster, you need to have the following software installed on your system:
- Docker: You can install Docker by following the instructions in the [Docker Installation](Docs/commands_breakdown.md#docker-installation) document.
- Docker Compose: You need to have Docker Compose installed to deploy the services. Review the official documentation [here](https://docs.docker.com/compose/install/) for installation instructions if not included in your Docker installation.
- Necessary images: You need to have the necessary Docker images for Hadoop and Spark. You can pull the images by running the following commands:
```bash
docker pull bitnami/spark:3.5.5
docker pull apache/hadoop:3.4.1
# Not necessary but highly recommended for the master nodes
docker pull jupyter/pyspark-notebook:latest
```

## Docker Swarm Setup

The first step is to create a Docker Swarm if you haven't done so already. You can do this by running the following command on the master node (for the initial tests you can use whatever node you want, either a complete linux installation or a VM):
```bash
docker swarm init --advertise-addr <master-ip>
```

Copy the token that is generated after running the command, as it will be used to join the worker nodes to the swarm.

Then, join the worker nodes to the swarm by running the following command on each worker node:
```bash
# On each worker node
docker swarm join --token <token> <master-ip>:2377
```

After joining the nodes, verify that the nodes are part of the swarm by running `docker node ls` on the master node, keep the node ID'S and hostnames to label the nodes later.

Then you need to create the overlay network that will be used by the services with:
```bash
docker network create -d overlay --attachable hadoop_spark_net
```

Label the nodes with the `h-role` label to identify the master and worker nodes. This operations is done on the manager node, so you can run the following commands to label the nodes:
```bash
# For the master node
docker node update --label-add spark-role=master <master-node-id>
# For the worker nodes
docker node update --label-add h-role=worker <worker-node-id>
docker node update --label-add spark-role=worker <worker-node-id>
```
You can replace `<master-node-id>` and `<worker-node-id>` with either the node ID or the hostname of the nodes if there are not any duplicated hostnames in the cluster.

On each node you need to create the next directories to store the HDFS data:
```bash
sudo mkdir -p /data/hadoop
sudo chmod 777 /data/hadoop
```

After all the nodes are labeled and the directories are created, you can deploy the services using Docker Compose using:
```bash
docker stack deploy -c docker-compose.yml <stack-name>
```

You can replace `<stack-name>` with the name you want to give to the stack. But I strognly recommend using short names as access to the containers is done using the stack name and the service name, so if you use long names it will be tedious to access the containers.

Check the status of the services by running:
```bash
docker service ls
```
If everything is working correctly, you should see the services running and the replicas for each service.
Also, if you want to see the logs of a specific service, you can run:
```bash
docker service logs <stack-name>_<service-name>
```

After everything is running correctly, you can access the Hadoop and Spark web UIs by going to the following URLs in your web browser:
- Hadoop Web UI: `http://<master-ip>:9870`
- Spark Web UI: `http://<master-ip>:8080`
- Jupyter Lab: `http://<master-ip>:8888/lab`

Follow the steps on the [Execution Steps](Docs/Detailed-steps/Execution-steps.md) document to perform a really simple test to check if the Hadoop cluster is working correctly.

## Important Notes

When you try to deploy the services is important to keep in mind the file structure, as the scripts are using relative paths to the files, so you need to keep the basic structure of the repository to avoid errors.

The basic structure of the repository is as follows:

```
dockerized-spark-cluster-set-up/           # Root repository
│
├── README.md                              # Main documentation
│
├── Docs/                                  # Contains all deployment files
│   │
│   ├── docker-compose.yml                 # Main deployment configuration
│   │
│   ├── hadoop-config/                     # Hadoop configuration files
│   │   ├── core-site.xml
│   │   └── hdfs-site.xml
│   │
│   ├── init-datanode.sh                   # DataNode initialization script
│   ├── start-hdfs.sh                      # HDFS startup script
│   ├── spark-start.sh                     # Spark startup script
│   │
│   └── [Documentation files...]           # Various markdown documentation files
│
└── [Other repository files...]            # .gitignore, etc.
```

If you want to copy only the necessary files to deploy the services, you should keep the following structure:
```
DEPLOYMENT-DIRECTORY/                      # Any directory on the swarm manager
│
├── docker-compose.yml                     # Main deployment configuration
│
├── hadoop-config/                         # Must be in this subdirectory
│   ├── core-site.xml
│   └── hdfs-site.xml
│
├── init-datanode.sh                       # Must be in same directory as docker-compose.yml
├── start-hdfs.sh
└── spark-start.sh
```

You have to run the `stack deploy` command in the same directory as the `docker-compose.yml` file.

