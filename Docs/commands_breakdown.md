# Why this document?
Some of the technologies and commands used in this project are not common and might be confusing or not self-explanatory. This document is created to explain the more confusing commands used on some of the files in the cluster setup.

# Docker

## Container Management
### List all containers (active and inactive)
```bash
docker ps -a
```

### List all active containers
```bash
docker ps
```
`Docker ps`, in contrast to `docker ps -a`, only shows active containers, which is useful when you only want to see the containers that are currently running as you might have a lot of inactive containers.

### Stop a container
```bash
docker stop <container-id>
```

### Start a container
```bash
docker start <container-id>
```
`Docker start` "starts" a container that was previously stopped, which differs from `docker run` that creates a new container.

### Create a new container
```bash
docker run -it <image-name>
```
`Docker run` creates a new container from an image. The `-it` flag is used to run the container in interactive mode, which will allow you to interact with the container's shell.
Every image has different configurations and requirements, so you might need to pass additional flags to the `docker run` command to properly configure the container depending on the image you are using.
An example of this using the spark cluster:
```bash
docker run -d --name spark-master \
    --network spark-network \
    -e SPARK_MODE=master \
    -p 8080:8080 \
    -p 7077:7077 \
    bitnami/spark:latest
```
In this example, we are creating a new container from the `bitnami/spark:latest` image. We are naming the container `spark-master`, connecting it to the `spark-network`, setting the `SPARK_MODE` environment variable to `master`, and exposing the ports `8080` and `7077`.

You will need to check the image's documentation (Or do your own research if not available) to know which flags you need to pass to the `docker run` command.

### Remove a container
```bash
docker rm <container-id>
```

## Docker Installation

To install Docker on Debian, you can use the following commands:

```bash
# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
# Add Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Use the following command to set up the stable repository. To add the nightly or test repository, add the word nightly or test (or both) after the word stable in the commands below. Learn about nightly and test channels.
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version:
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

After installing Docker, you can start the Docker service with the following command:
```bash
sudo systemctl start docker
```

## Docker Compose/Stack Commands

To deploy services on a Swarm with Docker Compose, you use the command:

```bash
docker stack deploy -c docker-compose.yml <stack-name>
```

This command will deploy the services defined in the `docker-compose.yml` file to the Docker Swarm with the specified stack name. You can check the status of the services by running the following command:

```bash
docker service ls
```

This will show the services running in the swarm. You can also check the status of the containers by running `docker ps` on the nodes.

