#!/bin/bash

server_ip=$(hostname -I | awk '{print $1}')
# Funktion zum Überprüfen, ob ein Befehl vorhanden ist
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Funktion zur Installation von Docker und Docker Compose
docker_installation() {
    # überprüfen ob docker installiert ist oder nicht
    if ! command_exists docker; then
        # Updaten der package list
        sudo apt update > /dev/null 2>&1

        # Installiere Notwendige software
        sudo apt install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg-agent \
            software-properties-common

        # Installieren von docker
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        sudo echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        sudo apt update > /dev/null 2>&1
        sudo apt install -y docker-ce docker-ce-cli containerd.io

        sudo echo "Docker erfolgreich installiert. ✅"
    else
        sudo echo "Docker ist bereits installiert. ✅"
    fi

    # überprüfen ob docker installiert ist
    if ! command_exists docker-compose; then
        # Instaliren von Docker-Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

        sudo chmod +x /usr/local/bin/docker-compose

        echo "Docker Compose erfolgreich installiert. ✅"
    else
        echo "Docker Compose ist bereits installiert. ✅"
    fi

    # Anzeigen von Docker und Docker-Compose version
    sudo docker --version
    sudo docker-compose --version
}

create_folders() {
    # Erstelleln von Ordner syncthing
    mkdir -p /opt/M122/syncthing

    # Erstelleln von Ordner docker
    mkdir -p /opt/M122/docker

    # Erstelleln von Ordner grafana
    mkdir -p /opt/M122/grafana

    # Erstelleln von Ordner loki
    mkdir -p /opt/M122/loki

    # Erstelleln von Ordner promtail
    mkdir -p /opt/M122/promtail

    # installieren von der loki Konfigurationsdatei
    wget -O /opt/M122/loki/loki-config.yaml https://raw.githubusercontent.com/Zubcal/m122/main/dashboard-server/loki-config.yaml > /dev/null 2>&1

    # installieren von der Promtail Konfigurationsdatei
    wget -O /opt/M122/promtail/promtail-config.yaml https://raw.githubusercontent.com/Zubcal/m122/main/dashboard-server/promtail-config.yaml > /dev/null 2>&1

    # installieren von der Docker-Compose datei
    wget -O /opt/M122/docker/docker-compose.yaml https://raw.githubusercontent.com/Zubcal/m122/main/dashboard-server/docker-compose.yaml > /dev/null 2>&1
}

check_logs_existence() {
    while true; do
        if [[ -f "/opt/M122/syncthing/nextcloud-logs/nextcloud/audit.log" && -f "/opt/M122/syncthing/nextcloud-logs/nextcloud/nextcloud.log" ]]; then
            echo "Audit- und Nextcloud-Logs wurden gefunden. Docker-Compose wird gestartet."
            break
        else
            echo "Audit- und/oder Nextcloud-Logs werden noch nicht gefunden. Warte 5 Sekunden..."
            sleep 5
        fi
    done
}

install_syncthing() {


 docker run -d \
  --name syncthing \
  --hostname syncthing \
  -v /opt/M122/syncthing/:/var/syncthing/ \
  -e PUID=0 \
  -e PGID=1000 \
  -e TZ=Europe/Zurich \
  -p 8384:8384 \
  -p 22000:22000/tcp \
  -p 22000:22000/udp \
  -p 21027:21027/udp \
  --restart unless-stopped \
  syncthing/syncthing:latest



    echo "Syncthing wird installiert. Bitte warten..."
    sleep 30  # Warte 30 Sekunden

    # Zeige die Syncthing-Gerät-ID an
    current_device_id=$(sudo docker exec -t syncthing syncthing --device-id)
    echo "❕ Dies ist Syncthing-Gerät-ID  bitte füge diese ID in ihrem Monitoring Syncthing ein: $current_device_id"


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

    # verbinden mit dem Gerät Monitoring

    sudo docker exec -t syncthing syncthing cli config devices add --device-id "$monitoring_id" --name monitoring --addresses dynamic --auto-accept-folders
    echo "Gerät 'Monitoring' wurde zu Syncthing hinzugefügt. ✅ "

    echo "Bitte warten ..."
    sleep 10  # Warte 10 sekunden

    check_logs_existence

    # ausführung der des Docker-Compose befehl (grafana loki & promtail)
    sudo docker-compose -f /opt/M122/docker/docker-compose.yaml up -d

    echo "Grafana, loki & Promtail werden insralliert ..."
    sleep 150  # Warte 150 sekunden

    
    # user bescheid geben das er auf das Dahboard via der ip adresse und port 3000 zugreifen kann
    echo "Grafana-Dashboard ist nun erreichbar unter: http://${server_ip}:3000 🌐"

}

# Schritt 1: Installation von Docker und Docker Compose
docker_installation

# Schritt 2: Erstellen von Ordnern für Syncthing und Scripts
create_folders

# Schritt 3: Installieren von Syncthing mit Docker Compose
install_syncthing
