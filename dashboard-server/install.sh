#!/bin/bash

# Funktion zum Überprüfen, ob ein Befehl vorhanden ist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Funktion zur Installation von Docker und Docker Compose
docker_installation() {
    # Check if Docker is installed
    if ! command_exists docker; then
        # Update the package list
        sudo apt update > /dev/null 2>&1

        # Install required dependencies
        sudo apt install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common \
            jq \
            ssmtp \
            mailutils \
            inotify-tools

        # Install Docker
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        sudo echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update > /dev/null 2>&1
        sudo apt install -y docker-ce docker-ce-cli containerd.io

        sudo echo "Docker erfolgreich installiert. ✅"
    else
        sudo echo "Docker ist bereits installiert. ✅"
    fi

    # Check if Docker Compose is installed
    if ! command_exists docker-compose; then
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

        sudo chmod +x /usr/local/bin/docker-compose

        echo "Docker Compose erfolgreich installiert. ✅"
    else
        echo "Docker Compose ist bereits installiert. ✅"
    fi

    # Display Docker and Docker Compose versions
    sudo docker --version
    sudo docker-compose --version
}

create_folders() {
    # Create folder for Syncthing
    mkdir -p /opt/M122/syncthing

    # Ensure that the docker folder exists
    mkdir -p /opt/M122/docker

    # Ensure that the docker folder exists
    mkdir -p /opt/M122/grafana

    # Ensure that the docker folder exists
    mkdir -p /opt/M122/loki

    # Ensure that the docker folder exists
    mkdir -p /opt/M122/promtail

    # installieren von dem log firmatieren script
    wget -O /opt/M122/scripts/log_formating.sh https://raw.githubusercontent.com/Zubcal/m122/main/monitoring-server/log_formating.sh > /dev/null 2>&1

    sudo chmod +x /opt/M122/scripts/log_formating.sh
    
    # Service file herunterladen
    wget -O /etc/systemd/system/log_formating.service https://raw.githubusercontent.com/Zubcal/m122/main/monitoring-server/log_formating.service > /dev/null 2>&1
}
