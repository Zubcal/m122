#!/bin/bash

# Funktion zum Überprüfen und Ausgeben des Nextcloud-Status
check_nextcloud_status() {
    status_output=$(sudo docker exec -t --user www-data nextcloud /var/www/html/occ status)
    
    echo "Nextcloud Status:"
    echo "$status_output"
    
    # Überprüfen, ob Nextcloud installiert ist
    if [[ $status_output == *"installed: true"* ]]; then
        echo "Nextcloud ist installiert"

        # Inhalt für die config.php-Datei
        config_content=$(cat <<EOL
  'loglevel' => 1,
  'log_type' => 'file',
  'logfile' => '/var/log/nextcloud.log',
  'log_type_audit' => 'file',
  'logfile_audit' => '/var/log/audit.log',
  'logdateformat' => 'd. F Y H:i:s',
EOL
)

        # Pfad zur config.php-Datei
        config_file_path="/opt/M122/nextcloud/data/config/config.php"

        # Überprüfen, ob der Text bereits vorhanden ist
        if ! sudo grep -q "'loglevel' => 1," "$config_file_path"; then
            # Einfügen des Inhalts in die config.php-Datei mit ed
            sudo ed -s "$config_file_path" <<EOF
/'datadirectory' => '\/var\/www\/html\/data'/a
$config_content
.
w
q
EOF

            echo "Inhalt wurde in $config_file_path eingefügt."
        else
            echo "Der Text ist bereits vorhanden."
        fi

        exit 0  # Das Skript beenden, da Nextcloud installiert ist
    else
        echo "Nextcloud ist noch nicht installiert"
    fi
}

server_ip=$(hostname -I | awk '{print $1}')

# Meldung an den Benutzer ausgeben
echo "Öffnen Sie einen Webbrowser und gehen Sie zur folgenden Adresse, um Nextcloud zu installieren:"
echo "http://${server_ip}:1880"

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

sudo mkdir -p /opt/M122

# Create subdirectories syncthing, nextcloud, and docker inside /opt/M122
sudo mkdir -p /opt/M122/syncthing
sudo mkdir -p /opt/M122/nextcloud
sudo mkdir -p /opt/M122/docker

#  Create subdirectories data, logs, and docker inside /opt/M122/nextcloud
sudo mkdir -p /opt/M122/nextcloud/data
sudo mkdir -p /opt/M122/nextcloud/logs
sudo mkdir -p /opt/M122/nextcloud/docker

# Download the docker-compose.yaml file to /opt/M122/docker
sudo wget -O /opt/M122/docker/docker-compose.yaml https://raw.githubusercontent.com/Zubcal/m122/main/nextcloud-server/docker-compose.yaml

# Download the .env file to /opt/M122/docker
sudo wget -O /opt/M122/docker/.env https://raw.githubusercontent.com/Zubcal/m122/main/nextcloud-server/.env

# Download the docker-entrypoint.sh file to /opt/M122/nextcloud/docker
sudo wget -O /opt/M122/nextcloud/docker/docker-entrypoint.sh https://github.com/Zubcal/m122/blob/main/nextcloud-server/docker-entrypoint.sh

# Create the "nextcloud" network
docker network create nextcloud

# Run docker-compose up -d in /opt/M122/docker
sudo docker-compose -f /opt/M122/docker/docker-compose.yaml up -d

# Endlosschleife für die Überprüfung alle 3 Minuten
timeout=$((SECONDS+300))
while [ $SECONDS -lt $timeout ]; do
    check_nextcloud_status
    sleep 10  # Warte 10 Sekunden zwischen den Überprüfungen
done

echo "Timeout erreicht. Das Skript wird beendet, auch wenn die Installation noch nicht abgeschlossen ist."
