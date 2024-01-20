#!/bin/bash

# Funktion zum Überprüfen und Ausgeben des Nextcloud-Status
server_ip=$(hostname -I | awk '{print $1}')

# Variable zur Überprüfung, ob die Meldung bereits angezeigt wurde
install_message_displayed=false

# Funktion zum Überprüfen und Ausgeben des Nextcloud-Status
check_nextcloud_status() {
    status_output=$(sudo docker exec -t --user www-data nextcloud /var/www/html/occ status)

    # Überprüfen, ob Nextcloud installiert ist
    if [[ $status_output == *"installed: true"* ]]; then
        echo " ✔ Nextcloud ist installiert"

        # Inhalt für die config.php-Datei
        config_content=$(cat <<EOL
  'loglevel' => 1,
  'log_type' => 'file',
  'logfile' => '/var/www/html/data/nextcloud.log',
  'log_type_audit' => 'file',
  'logfile_audit' => '/var/www/html/data/audit.log',
  'logdateformat' => 'd. F Y H:i:s',
EOL
)

        # Pfad zur config.php-Datei
        config_file_path="/opt/M122/nextcloud/config/config.php"

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

            echo "logs kofiguration wurde in $config_file_path eingefügt. ✅"
        else
            echo " ✔ Die logs sind bereits eingerichtet."
        fi

        # Befehle für Audit-Logging aktivieren
        sudo docker exec -t --user www-data nextcloud /var/www/html/occ config:app:set admin_audit logfile --value=/var/www/html/data/audit.log
        sudo docker exec -t --user www-data nextcloud /var/www/html/occ app:enable admin_audit

        exit 0  # Das Skript beenden, da Nextcloud installiert ist
    fi

    # Meldung an den Benutzer ausgeben, wenn Nextcloud noch nicht installiert ist
    if [ "$install_message_displayed" = false ]; then
        echo "Nextcloud ist noch nicht installiert"
        echo "Bitte Öffne einen Webbrowser und gehe zur folgenden Adresse, um Nextcloud zu installieren: http://${server_ip}:1880 🌐"
        install_message_displayed=true
    fi
}





# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    # Update the package list
    sudo apt update > /dev/null 2>&1

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

    sudo apt update > /dev/null 2>&1
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    echo "Docker erfolgreich installiert. ✅"
else
    echo "Docker ist bereits installiert. ✅"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

    sudo chmod +x /usr/local/bin/docker-compose

    echo "Docker Compose erfolgreich installiert. ✅"
else
    echo "Docker Compose ist bereirts installiert. ✅"
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
sudo mkdir -p /opt/M122/nextcloud/config
sudo mkdir -p /opt/M122/nextcloud/docker

# Download the docker-compose.yaml file to /opt/M122/docker
sudo wget -O /opt/M122/docker/docker-compose.yaml https://raw.githubusercontent.com/Zubcal/m122/main/nextcloud-server/docker-compose.yaml > /dev/null 2>&1

# Download the .env file to /opt/M122/docker
sudo wget -O /opt/M122/docker/.env https://raw.githubusercontent.com/Zubcal/m122/main/nextcloud-server/.env > /dev/null 2>&1

# Download the docker-entrypoint.sh file to /opt/M122/nextcloud/docker
sudo wget -O /opt/M122/nextcloud/docker/docker-entrypoint.sh https://github.com/Zubcal/m122/blob/main/nextcloud-server/docker-entrypoint.sh > /dev/null 2>&1

# Überprüfen, ob das Docker-Netzwerk namens "nextcloud" existiert
if ! sudo docker network inspect nextcloud &> /dev/null; then
    # Das Netzwerk existiert nicht, erstelle es
    sudo docker network create nextcloud
fi

# Run docker-compose up -d in /opt/M122/docker
sudo docker-compose -f /opt/M122/docker/docker-compose.yaml up -d

# Endlosschleife für die Überprüfung alle 3 Minuten
while true; do
    check_nextcloud_status
    sleep 5  # Warte 5 Sekunden zwischen den Überprüfungen
done
