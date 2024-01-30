# Shell-Skript-Dokumentation Für den Monitoring server

## Inhaltsverzeichnis
1. [Einführung](#einführung)
2. [Funktionsweise des Skripts](#funktionsweise-des-skripts)
3. [Anforderungen](#anforderungen)
4. [Installation von Docker und Docker Compose](#installation-von-docker-und-docker-compose)
5. [Erstellen von Ordnern für Syncthing und Skripte](#erstellen-von-ordnern-für-syncthing-und-skripte)
6. [Installieren von Syncthing mit Docker Compose](#installieren-von-syncthing-mit-docker-compose)
7. [Konfiguration von E-Mails mit sSMTP](#konfiguration-von-e-mails-mit-ssmtp)
8. [Bilder](#bilder)

## Einführung
Dieses Shell-Skript automatisiert die Installation und Konfiguration von Docker, Docker Compose, Syncthing und sSMTP für die Verwendung in einem Überwachungssystem. Es bietet auch die Möglichkeit, E-Mail-Benachrichtigungen über sSMTP zu konfigurieren.

## Funktionsweise des Skripts
Das Skript besteht aus verschiedenen Funktionen, die nacheinander aufgerufen werden, um die Installation und Konfiguration der erforderlichen Komponenten durchzuführen.

## Anforderungen
Um dieses Skript erfolgreich ausführen zu können, sind folgende Anforderungen zu erfüllen:
- Ein Linux-System (getestet unter Ubuntu).
- Eine Internetverbindung für den Download von Paketen und Dateien.
- Erforderliche Berechtigungen, um sudo-Befehle ausführen zu können.

## Installation von Docker und Docker Compose
Die Funktion `docker_installation()` überprüft zunächst, ob Docker und Docker Compose bereits installiert sind. Falls nicht, werden sie installiert, indem die benötigten Pakete und Abhängigkeiten heruntergeladen und installiert werden.

## Erstellen von Ordnern für Syncthing und Skripte
Die Funktion `create_folders()` erstellt die benötigten Ordner für Syncthing und Skripte. Zusätzlich werden ein Skript (`log_formating.sh`) und eine Service-Datei (`log_formating.service`) von einem GitHub-Repository heruntergeladen und in die entsprechenden Ordner kopiert.

## Installieren von Syncthing mit Docker Compose
Die Funktion `install_syncthing()` lädt eine Docker-Compose-Datei von einem GitHub-Repository herunter und platziert sie im Ordner `/opt/M122/docker`. Anschließend wird Syncthing mithilfe von Docker Compose gestartet und konfiguriert, um mit anderen Geräten zu kommunizieren.

## Konfiguration von E-Mails mit sSMTP
Die Funktion `configure_email()` fordert den Benutzer auf, E-Mail-Konfigurationsdetails einzugeben, um sSMTP zu konfigurieren. Diese Details werden dann in der Konfigurationsdatei von sSMTP gespeichert und an ein Skript (`log_formating.sh`) übergeben, um E-Mail-Benachrichtigungen zu ermöglichen.

## Bilder
### Syncthing
![Syncthing](https://github.com/Zubcal/m122/assets/127558095/0de2d4a3-3cbc-473c-a139-4e5f1e3dab9e)

- **Beschreibung:** Bild, das Syncthing während der Synchronisierung zeigt.

### Gmail
![Gmail](https://github.com/Zubcal/m122/assets/127558095/32c7f32c-66ce-44fc-84bf-f2f073bb4690)

- **Beschreibung:** Bild, das die Gmail-Plattform zeigt, über die E-Mail-Benachrichtigungen gesendet werden.

