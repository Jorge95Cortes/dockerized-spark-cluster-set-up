# Docker Swarm Explained

Docker Swarm is a container orchestration tool that allows you to manage a cluster of Docker nodes across multiple machines, as Docker Networks are limited to multiple containers on the same host, but we're looking to multiple containers on multiple hosts. Due to Docker Swarm being a built-in feature of Docker, it is not necessary to install any additional software to use it.

## Network Simulation

Same as in the initial testing, we're going to use the virtual machine and the WSL2 distribution to simulate a LAN network.

## Creating a Swarm

The first step is to create a "Docker Swarm", which can be done by running the following command:

```bash
# On the master node
docker swarm init --advertise-addr <master-ip>
```

This will return a token that can be used to join other nodes to the swarm. You can find the token in the output of the command and it will have a format similar to this:

```bash
SWMTKN-1-xxxxxxxx
```

The output may include some additional information including your IP address and the port number of the swarm manager which is `2377`.
But the token is the key part, including the `SWMTKN-1-` prefix.
Ensure to keep it at hand as it will be used to join the worker nodes to the swarm.

You can also get the token by running the following command:

```bash
docker swarm join-token worker
# or
docker swarm join-token manager
```

This will return the token that can be used to join a worker or manager node to the swarm.

## Joining a node to the Swarm

To join a node to the swarm, you need to run the following command on the worker node:

```bash
docker swarm join --token <token> <master-ip>:2377
```

You'll see a message saying that the node has joined the swarm. You can check the status of the nodes in the swarm by running the following command on the master node:

```bash
docker node ls
```

Here you should see the master node and the worker node listed as "Ready".

It is important to note that only a manager node can create services and manage the swarm, while worker nodes can only run services. In this case, the master node is the manager node and the worker node is a worker node.

## Creating an overlay network

While Docker has built-in networking capabilities, the Docker Networks are limited to multiple containers on the same host. To create a network that spans multiple hosts, we need to create an "overlay network", which is a network that connects multiple nodes in a Docker Swarm.
To create an overlay network, you can run the following command on the master node:

```bash
docker network create --driver overlay <network-name>
# Alternatively, you can use the following command with the --driver flag shortened to -d
docker network create -d overlay <network-name>
```

An example of the command would be:

```bash
docker network create -d overlay spark-cluster-net
```

This will create an overlay network that spans all the nodes in the swarm. You can check the status of the network by running the following command on the master node:

```bash
docker network ls
```

You should see the overlay network listed in the output.

## Labeling nodes

To manage the containers in the swarm, we can use labels to identify the nodes. This is useful for running specific containers on specific nodes or for load balancing purposes.
To label nodes, you can run the following command on the master node:

```bash
docker node update --label-add <label>=<value> <node-id>
```

Here, the <label> value is the name of the label you want to add, and has no specific format or restrictions. The <value> is the value of the label, and the <node-id> is the ID of the node you want to label which you can find by running the `docker node ls` command, you could also use the node name instead of the node ID, but the ID is more reliable to avoid conflicts of duplicated names.

In this spark cluster example, we can label the nodes as "master" and "worker" to identify their roles. To do this, you can run the following commands:

```bash
docker node update --label-add spark-role=master <master-node-id>
docker node update --label-add spark-role=worker <worker-node-id>
```

We can see the labels of a node by inspecting the node. To do this, you can run the command `docker node inspect <node-id>`.

## Docker Compose for Swarm Deployment

So far, I've been using the oficial Spark image to create the containers, but this image is not suitable for a cluster environment as it requires manual configuration of the master and worker nodes, and due to some redundancy in the configuration, it is likely to cause issues in a real-world scenario, as I've been experiencing in the tests.

For simplicity, I'll be using the Bitnami Spark image, which is a pre-configured image that is prepared to set up a cluster out of the box. The Bitnami Spark image is available on the Docker Hub and can be pulled with the following command:

```bash
docker pull bitnami/spark:latest
```

Also, I'd like to mention the example provided by Eithan on it's [docker-cluster repo](https://github.com/eithan-hernandez/docker-cluster/tree/main), and I'll be using the same image and similar configurations to set up the Spark cluster.

Deploying services individually can be tricky, because you need to specify the network, volumes, and other configurations for each service, and with my current implementations, you require to specify network configurations for each container, including explicit IP addresses, to solve DNS issues, docker-compose will handle this for us, allowing to focus on the services and configurations.
