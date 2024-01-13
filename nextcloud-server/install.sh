#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    # Update the package list
    sudo apt update

    # Install required dependencies
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    sudo chmod +x /usr/local/bin/docker-compose

    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Display Docker and Docker Compose versions
docker --version
docker-compose --version

if id "m122" &>/dev/null; then
    echo "User 'm122' already exists."
else
    # Create user 'm122' and add to the sudo group
    sudo useradd -m -G sudo m122
    echo "m122 ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/m122

    echo "User 'm122' created and added to the sudo group."
fi

# Check if directory '/opt/M122' exists
if [ -d "/opt/M122" ]; then
    echo "Directory '/opt/M122' already exists."
else
    # Create directory '/opt/M122' and set ownership
    sudo mkdir -p /opt/M122
    sudo chown m122:m122 /opt/M122

    echo "Directory '/opt/M122' created with 'm122' as the owner."
fi

if [ -d "/opt/M122/docker" ]; then
    echo "Directory '/opt/M122/docker' already exists."
else
    # Create directory '/opt/M122/docker' and set ownership
    sudo mkdir -p /opt/M122/docker
    sudo chown m122:m122 /opt/M122/docker

    echo "Directory '/opt/M122/docker' created with 'm122' as the owner."
fi

# Check if directory '/opt/M122/nextcloud' exists
if [ -d "/opt/M122/nextcloud" ]; then
    echo "Directory '/opt/M122/nextcloud' already exists."
else
    # Create directory '/opt/M122/nextcloud' and set ownership
    sudo mkdir -p /opt/M122/nextcloud
    sudo chown m122:m122 /opt/M122/nextcloud

    echo "Directory '/opt/M122/nextcloud' created with 'm122' as the owner."
fi

# Check if directory '/opt/M122/syncthing' exists
if [ -d "/opt/M122/syncthing" ]; then
    echo "Directory '/opt/M122/syncthing' already exists."
else
    # Create directory '/opt/M122/syncthing' and set ownership
    sudo mkdir -p /opt/M122/syncthing
    sudo chown m122:m122 /opt/M122/syncthing

    echo "Directory '/opt/M122/syncthing' created with 'm122' as the owner."
fi


if [ ! -f "/opt/M122/docker/docker-compose.yaml" ]; then
    sudo wget -O /opt/M122/docker/docker-compose.yaml https://raw.githubusercontent.com/Zubcal/m122/main/nextcloud-server/docker-compose.yaml
    echo "docker-compose.yaml downloaded to '/opt/M122/docker'."
else
    echo "docker-compose.yaml already exists in '/opt/M122/docker'."
fi
