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

If you're using WSL2, you can find the IP address by running the following command:
```bash
hostname -I
```

Which, due to the mirrored network configuration, will return the IP address of the Windows host.