# Target
In this repo, I'll cover some of the steps I took to set up a Spark cluster with up to 20 nodes using Docker. One key point to note is that the cluster uses containers created on WSL for Windows as well as containers set up on a Linux machine. This documentation covers everything from installing the required software to making network adjustments and includes tests and reports along the way.
First things first, let's get the software installed.
# Software Installation
## Docker
To install Docker on Debian, you can see the official documentation [here](https://docs.docker.com/engine/install/debian/). Based on my experience, I recommend using docker desktop as it is more intuitive and user-friendly, but you can just install the docker engine if you prefer or have limited resources, also this is what you're likely found on real work environments.

To install Docker on Windows, you can use the following link: [Docker Desktop](https://www.docker.com/products/docker-desktop) (I suggest to see the next section before). It is important to note that Docker Desktop runs a Linux VM in the background, and you will need to enable WSL2 to run Linux containers.
Also, it is recommended to install a Linux distribution on WSL2 to interact with the containers in a more efficient way. I'll be using Debian 12 for this documentation.
So, let's start by installing WSL2 with Debian 12.
## WSL2 (Only for those who don't want or can't use Linux)
To install WSL2 on Windows, you can follow the official documentation [here](https://docs.microsoft.com/en-us/windows/wsl/install).
A key point is that you need to have Windows 10 version 1903 (AKA Windows 10, for simplicity) or higher to install WSL2, is also required to have a machine capable of running virtualization.

A simple guide to install WSL2 is as follows:
```PowerShell
# In PowerShell as Administrator
wsl --install -d Debian
```
After the installation is complete, you can access the Debian terminal by typing `wsl` in the Windows terminal and it will ask you to set up a username and password.
## Docker on WSL2
It is preferable to not install Docker on WSL2 as it can cause issues with the Docker Desktop installation. Instead, you can use the Docker Desktop to manage the containers on WSL2.
To do this, you need to enable the WSL2 integration in the Docker Desktop settings.
1. Open Docker Desktop
2. Go to Settings
3. Go to Resources
4. Go to WSL Integration
5. Enable the integration for the WSL2 distribution you want to use
6. Click Apply & Restart

It should look like this:
![WSL Integration](assets/WSL_resource_config.png)
Keep in mind that the docker commands will only work on the WSL2 terminal if you have Docker Desktop running.

## Network Configuration on WSL2
To avoid issues with WSL networking, and based on my experience, it is recommended to switch the WSL2 network configuration from NAT to the Mirrored mode. This will replicate the interfaces from the Windows host to the WSL2 distribution, making it easier to access the containers from the Windows host.
In order to do this, you will need to create a `.wslconfig` file in your user directory with the following content:
```bash
[wsl2]
networkingMode=mirrored
```
After creating the file, you will need to restart the WSL2 distribution if running. After that, you should be able to access the containers from the Windows host using the IP address of the WSL2 distribution.

# Initial Containers test
To test the Docker installation, you can run the following command:
```bash
docker run hello-world
```
If everything is working correctly, you should see a message saying that the installation was successful.

## Spark containers
First, we need to create a container with the Spark image. To do this, is necessary to pull the image from the Docker Hub, there are different versions of the image, such as Spark, Apache/Spark, and Bitnami/Spark as the most popular ones. For this test I used the Spark official image, but the final choice is still not defined, which will be based on the researchs and tests that are being done by other teams and myself.
To pull the image, you can use the following command:
```bash
docker pull spark:latest
```
This test is using the host network mode, which means that the container will use the host network interface. This is very likely to change in the future, but for now, it is a simple way to test the Spark container with a virtual machine and a WSL2 distribution.
We're going to create two containers, one for the master and one for the worker. The master container will be created with the following command:
```bash
docker run -d   --name spark-master   --network=host -e SPARK_MASTER_HOST=<master-ip>   -e SPARK_MASTER_WEBUI_HOST=0.0.0.0   spark:latest   /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master
```
In this command, you need to replace `<master-ip>` with the IP address of your computer without the brackets. If you're using WSL2, you can find the IP address by running the following command:
```bash
hostname -I
```
Which, due to the mirrored network configuration, will return the IP address of the Windows host.
After running the command, you can access the Spark UI by going to `http://<master-ip>:8080` in your brovirwser. You should see the Spark master UI with no workers connected.
It might look like this:
![Spark Master UI](assets/Spark-master-web-UI.png)
Now, let's create the worker container. The worker container will be created with the following command:
```bash
docker run -d   --name spark-worker   -p 8081:8081   -e SPARK_WORKER_WEBUI_HOST=0.0.0.0   -e SPARK_LOCAL_IP=0.0.0.0   spark:latest   /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://<master-ip>:7077
```
Again, replace `<master-ip>` with the IP address of the master computer. After this container is running, you should see the worker connected to the master in the Spark UI.
It might look like this:
![Spark Worker UI](assets/Spark-worker-connected.png)
Great! Now both the master and worker containers are running and connected. I'll test the Spark cluster with a simple application in the next section.

## Running a simple Spark application
We're going to run a simple Spark application to test the cluster. This application is already included in the Spark image and can be run with the following command:
```bash
docker exec spark-master   /opt/spark/bin/spark-submit   --master spark://<master-ip>:7077   --conf spark.driver.host=192.168.3.48   --class org.apache.spark.examples.SparkPi   /opt/spark/examples/jars/spark-examples_2.12-3.5.4.jar 100
```
This command will run the SparkPi example application, which calculates an approximation of Pi using the Monte Carlo method. The number `100` at the end of the command is the number of iterations the application will run. You can change this number to increase or decrease the accuracy of the approximation.
After running the command, you should see the output of the application in the terminal. It will show the value of Pi calculated by the application.
The final result might look like this:
![Spark Pi Result](assets/SparkPi-testrun.png)
Also, you will notice that the Spark UI will show the application in the "Completed Applications" section, or in the "Running Applications" section if the application is still running.
It might look like this:
![Spark Pi Application](assets/Completed-app-web-UI.png)

And that's the end of the initial test. Some of the next steps will include setting up a more complex network configuration, avoiding the use of the host network mode, creating a Docker Compose file to manage the containers and include more tools in the cluster such as Hadoop, Jupyter, or other tools that might be required for the project. Let me know if you have any questions or suggestions for this or the next steps.