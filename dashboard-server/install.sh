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
    wget -O /opt/M122/loki/loki-config.yaml https://raw.githubusercontent.com/Zubcal/m122/main/dashboard-server/loki-config.yaml > /dev/null 2>&1

    # installieren von dem log firmatieren script
    wget -O /opt/M122/promtail/promtail-config.yaml https://raw.githubusercontent.com/Zubcal/m122/main/dashboard-server/promtail-config.yaml > /dev/null 2>&1
    
    # installieren von dem log firmatieren script
    wget -O /opt/M122/docker/docker-compose.yaml https://raw.githubusercontent.com/Zubcal/m122/main/dashboard-server/docker-compose.yaml > /dev/null 2>&1
}

install_syncthing() {

        # Überprüfen, ob das Docker-Netzwerk namens "nextcloud" existiert
    if ! sudo docker network inspect nextcloud &> /dev/null; then
        # Das Netzwerk existiert nicht, erstelle es
        sudo docker network create nextcloud
    fi

    # Run docker-compose up -d in /opt/M122/docker
    sudo docker-compose -f /opt/M122/docker/docker-compose.yaml up -d

    echo "Syncthing wird installiert. Bitte warten..."
    sleep 30  # Warte 30 Sekunden

    # Zeige die Syncthing-Gerät-ID
    current_device_id=$(sudo docker exec -t syncthing syncthing --device-id)
    echo "❕ Dies ist Syncthing-Gerät-ID  bitte füge diese ID in ihrem Monitoring Sycthing ein: $current_device_id"


    # Benutzer nach der ID des Syncthing vom Monotoring fragen und Überprüfung der Eingabe
    while true; do
        read -p "❕ Geben Sie die ID Ihres Monitoring für Syncthing ein: " monitoring_id </dev/tty

        # Überprüfen, ob die ID dem gewünschten Schema entspricht
        if [[ ! "$monitoring_id" =~ ^[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+$ ]]; then
            sudo echo "Ungültige Eingabe. Bitte geben Sie eine ID im richtigen Format ein❗️"
        else
            break
        fi
    done


    sudo docker exec -t syncthing syncthing cli config devices add --device-id "$monitoring_id" --name monitoring --addresses dynamic --auto-accept-folders
    echo "Gerät 'Monitoring' wurde zu Syncthing hinzugefügt. ✅ "

        # Überprüfen, ob Gerät 'Dashboard' bereits mit dem Ordner 'Monitoring' geteilt ist
    if ! sudo docker exec -t syncthing syncthing cli config folders "$syncthing_folder_check" devices list | grep -q "$dashboard_id"; then
        # Gerät 'Dashboard' zum Ordner 'Monitoring' hinzufügen
        sudo docker exec -t syncthing syncthing cli config folders "$syncthing_folder_check" devices add --device-id "$dashboard_id"
        echo "Gerät 'Dashboard' wurde zum Ordner 'Monitoring' hinzugefügt. ✅"
    else
        echo "Gerät 'Dashboard' ist bereits mit dem Ordner 'Monitoring' geteilt. ✅"
    fi

}

# Schritt 1: Installation von Docker und Docker Compose
docker_installation

# Schritt 2: Erstellen von Ordnern für Syncthing und Scripts
create_folders

# Schritt 3: Installieren von Syncthing mit Docker Compose
install_syncthing
