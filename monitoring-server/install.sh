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
            software-properties-common
            jq
            ssmtp
            mailutils
            inotify-tools

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
    if ! command_exists docker-compose; then
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
}

# Funktion zum Erstellen von Ordnern für Syncthing und Scripts
create_folders() {
    # Create folder for Syncthing
    sudo mkdir -p /opt/M122/syncthing

    # Create folder for scripts
    sudo mkdir -p /opt/M122/scripts

    # Ensure that the docker folder exists
    sudo mkdir -p /opt/M122/docker

    # installieren von dem log firmatieren script
    sudo wget -O /opt/M122/scripts/log_formating.sh https://raw.githubusercontent.com/Zubcal/m122/main/monitoring-server/log_formating.sh > /dev/null 2>&1
    
    # Service file herunterladen
    sudo wget -O /etc/systemd/system/log_formating.service https://raw.githubusercontent.com/Zubcal/m122/main/monitoring-server/log_formating.service > /dev/null 2>&1
}

# Funktion zum Installieren von Syncthing mit Docker Compose
install_syncthing() {
    # Download docker-compose.yaml to /opt/M122/docker
    sudo wget -O /opt/M122/docker/docker-compose.yaml https://raw.githubusercontent.com/Zubcal/m122/main/monitoring-server/docker-compose.yaml > /dev/null 2>&1

    # Run docker-compose up -d in /opt/M122/docker
    sudo docker-compose -f /opt/M122/docker/docker-compose.yaml up -d

    echo "Syncthing wird installiert. Bitte warten..."
    sleep 30  # Warte 30 Sekunden


    syncthing_folder_check=$(sudo docker exec -t syncthing syncthing cli config folders list | grep -o "monitoring")

    if [ -z "$syncthing_folder_check" ]; then
        # Syncthing-Ordner erstellen
        sudo docker exec -t syncthing syncthing cli config folders add --id monitoring --label monitoring --path /var/syncthing --type sendonly --ignore-perms
        echo "Syncthing-Ordner 'monotoring' wurde erstellt. ✅"
    else
        echo "Syncthing-Ordner 'monitoring' existiert bereits. ✅"
    fi

    # Zeige die Syncthing-Gerät-ID
    current_device_id=$(sudo docker exec -t syncthing syncthing --device-id)
    echo "❕ Dies ist Syncthing-Gerät-ID  bitte füge diese ID den nextcloud und grafana ein: $current_device_id"


    # Benutzer nach der ID des Syncthing von Nextcloud fragen und Überprüfung der Eingabe
    while true; do
        read -p "❕ Geben Sie die ID Ihres Nextcloud für Syncthing ein: " nexcloud_id </dev/tty

        # Überprüfen, ob die ID dem gewünschten Schema entspricht
        if [[ ! "$nexcloud_id" =~ ^[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+$ ]]; then
            echo "Ungültige Eingabe. Bitte geben Sie eine ID im richtigen Format ein❗️"
        else
            break
        fi
    done

    # Benutzer nach der ID des Syncthing vom Dashboard Server fragen und Überprüfung der Eingabe
    while true; do
        read -p "Geben Sie die ID Ihres Dashboard für Syncthing ein❕ : " dashboard_id </dev/tty

        # Überprüfen, ob die ID dem gewünschten Schema entspricht
        if [[ ! "$dashboard_id" =~ ^[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+-[A-Z0-9-]+$ ]]; then
            echo "Ungültige Eingabe. Bitte geben Sie eine ID im richtigen Format ein❗️"
        else
            break
        fi
    done

    sudo docker exec -t syncthing syncthing cli config devices add --device-id "$nexcloud_id" --name nextcloud --addresses dynamic --auto-accept-folders
    echo "Gerät 'nextcloud' wurde zu Syncthing hinzugefügt. ✅ "

    sudo docker exec -t syncthing syncthing cli config devices add --device-id "$dashboard_id" --name Dashboard --addresses dynamic
    echo "Gerät 'Dashboard' wurde zu Syncthing hinzugefügt. ✅"

        # Überprüfen, ob Gerät 'Dashboard' bereits mit dem Ordner 'Monitoring' geteilt ist
    if ! sudo docker exec -t syncthing syncthing cli config folders "$syncthing_folder_check" devices list | grep -q "$dashboard_id"; then
        # Gerät 'Dashboard' zum Ordner 'Monitoring' hinzufügen
        sudo docker exec -t syncthing syncthing cli config folders "$syncthing_folder_check" devices add --device-id "$dashboard_id"
        echo "Gerät 'Dashboard' wurde zum Ordner 'Monitoring' hinzugefügt. ✅"
    else
        echo "Gerät 'Dashboard' ist bereits mit dem Ordner 'Monitoring' geteilt. ✅"
    fi

}

# Funktion zur Konfiguration von E-Mails mit sSMTP
configure_email() {
    echo "Bitte geben Sie die erforderlichen E-Mail-Konfigurationsdetails ein:"

    read -p "Ihre E-Mail-Adresse (Absender): " from_email
    read -sp "Ihr E-Mail-Passwort: " email_password
    echo  # Neue Zeile einfügen
    read -p "E-Mail-Adresse des Empfängers: " to_email
    read -p "SMTP-Server-Adresse mit Port (z.B. smtp.server.com:587): " smtp_server

    # Konfigurationsdatei für sSMTP schreiben
    echo "# Mailkonfiguration für sSMTP" | sudo tee /etc/ssmtp/ssmtp.conf > /dev/null
    echo "root=$from_email" | sudo tee -a /etc/ssmtp/ssmtp.conf > /dev/null
    echo "mailhub=$smtp_server" | sudo tee -a /etc/ssmtp/ssmtp.conf > /dev/null
    echo "AuthUser=$from_email" | sudo tee -a /etc/ssmtp/ssmtp.conf > /dev/null
    echo "AuthPass=$email_password" | sudo tee -a /etc/ssmtp/ssmtp.conf > /dev/null

    # E-Mail-Adressen in das andere Skript einfügen
    sed -i "s/^FROM_EMAIL=.*/FROM_EMAIL=\"$from_email\"/" /opt/M122/scripts/log_formating.sh
    sed -i "s/^TO_EMAIL=.*/TO_EMAIL=\"$to_email\"/" /opt/M122/scripts/log_formating.sh

    echo "E-Mail-Konfiguration erfolgreich gespeichert."

    sudo systemctl start log_formating
    
    sudo systemctl enable log_formating
}

# Schritt 1: Installation von Docker und Docker Compose
docker_installation

# Schritt 2: Erstellen von Ordnern für Syncthing und Scripts
create_folders

# Schritt 3: Installieren von Syncthing mit Docker Compose
install_syncthing
