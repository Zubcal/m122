#!/bin/bash

# Funktion zum Überprüfen und Ausgeben des Nextcloud-Status
server_ip=$(hostname -I | awk '{print $1}')

# Variable zur Überprüfung, ob die Meldung bereits angezeigt wurde
install_message_displayed=false
nextcloud_installed=false
syncthing_installed=false

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

            echo "logs Kofiguration wurde in $config_file_path eingefügt. ✅"
        else
            echo " ✔ Die logs sind bereits eingerichtet."
        fi

        # .stignore-Datei erstellen oder Text aktualisieren
        stignore_path="/var/syncthing/.stignore"
        stignore_content=$(cat <<EOL
!nextcloud.log
!nextcloud/audit.log
*/
EOL
)

        if ! sudo docker exec -t syncthing grep -q "nextcloud.log" "$stignore_path"; then
            sudo docker exec -t syncthing sh -c "echo '$stignore_content' > $stignore_path"
            echo " ✔ .stignore-Datei wurde erstellt oder aktualisiert."
        else
            echo " ✔ .stignore-Datei existiert bereits und ist korrekt konfiguriert."
        fi

        # Befehle für Audit-Logging aktivieren
        sudo docker exec -t --user www-data nextcloud /var/www/html/occ config:app:set admin_audit logfile --value=/var/www/html/data/audit.log > /dev/null 2>&1
        sudo docker exec -t --user www-data nextcloud /var/www/html/occ app:enable admin_audit > /dev/null 2>&1


        # Überprüfen, ob der Ordner "nextcloud" bereits existiert
        syncthing_folder_check=$(sudo docker exec -t syncthing syncthing cli config folders list | grep -o "nextcloud")

        if [ -z "$syncthing_folder_check" ]; then
            # Syncthing-Ordner erstellen
            sudo docker exec -t syncthing syncthing cli config folders add --id nextcloud --label nextcloud-logs --path /var/syncthing --type sendonly --ignore-perms
            echo " ✔ Syncthing-Ordner 'nextcloud' wurde erstellt."
        else
            echo " ✔ Syncthing-Ordner 'nextcloud' existiert bereits."
        fi

        current_device_id=$(sudo docker exec -t syncthing syncthing --device-id)
        echo "❕ Dies ist Syncthing-Gerät-ID  bitte gib diese ID auf deinem Raspi: $current_device_id"

        # Benutzer nach der ID des Raspi fragen und Überprüfung der Eingabe
        while true; do
            read -p "❕ Geben Sie die ID Ihres Raspi für Syncthing ein: " raspi_id </dev/tty

            # Überprüfen, ob die ID dem gewünschten Schema entspricht
            if [[ ! "$raspi_id" =~ ^[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+$ ]]; then
                echo "❗️ Ungültige Eingabe. Bitte geben Sie eine ID im richtigen Format ein."
            else
                break
            fi
        done

        # ID in das Syncthing-Konfigurationsskript einfügen
        sudo docker exec -t syncthing syncthing cli config devices add --device-id "$raspi_id" --name raspi --addresses dynamic
        echo " ✔ Gerät 'raspi' wurde zu Syncthing hinzugefügt."

        # Überprüfen, ob Gerät 'raspi' bereits mit dem Ordner 'nextcloud' geteilt ist
        if ! sudo docker exec -t syncthing syncthing cli config folders "$syncthing_folder_check" devices list | grep -q "$raspi_id"; then
            # Gerät 'raspi' zum Ordner 'nextcloud' hinzufügen
            sudo docker exec -t syncthing syncthing cli config folders "$syncthing_folder_check" devices add --device-id "$raspi_id"
            echo " ✔ Gerät 'raspi' wurde zum Ordner 'nextcloud' hinzugefügt."
        else
            echo " ✔ Gerät 'raspi' ist bereits mit dem Ordner 'nextcloud' geteilt."
        fi

        exit 0  # Das Skript beenden, da Nextcloud und Syncthing installiert sind
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
    echo "Docker Compose ist bereits installiert. ✅"
fi

# Display Docker and Docker Compose versions
docker --version
docker-compose --version

sudo mkdir -p /opt/M122

# Create subdirectories nextcloud and docker inside /opt/M122
sudo mkdir -p /opt/M122/nextcloud
sudo mkdir -p /opt/M122/docker

# Create subdirectories data, logs, and docker inside /opt/M122/nextcloud
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

    # Wenn Nextcloud und Syncthing installiert sind, das Skript beenden
    if [ "$nextcloud_installed" = true ] && [ "$syncthing_installed" = true ]; then
        echo "Nextcloud und Syncthing sind installiert. Das Skript wird beendet."
        exit 0
    fi

    sleep 5  # Warte 5 Sekunden zwischen den Überprüfungen
done
