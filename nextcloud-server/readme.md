# Nextcloud und Syncthing Setup Skript

## Inhaltsverzeichnis
1. [Globale Variablen und Funktionen](#globale-variablen-und-funktionen)
2. [Hauptskript](#hauptskript)
3. [Ausführung](#ausführung)
4. [Bilder](#Bilder)

Dieses Bash-Skript dient dazu, eine Umgebung für Nextcloud und Syncthing aufzusetzen. Es überprüft die Installation von Docker und Docker Compose, erstellt benötigte Verzeichnisse und Dateien, startet Docker-Container und konfiguriert Nextcloud und Syncthing entsprechend.

## Globale Variablen und Funktionen

### `check_nextcloud_status()`

Diese Funktion überprüft den Status von Nextcloud und führt entsprechende Konfigurationsschritte aus.

1. **Status Überprüfung**: Die Funktion verwendet `sudo docker exec`, um den Status von Nextcloud abzurufen.
   
2. **Konfigurationsdateien**: Sie überprüft, ob die Konfigurationsdatei `config.php` existiert und fügt ggf. Log-Konfigurationen hinzu.

3. **.stignore-Datei**: Eine `.stignore`-Datei für Syncthing wird erstellt oder aktualisiert, um bestimmte Dateien auszuschließen.

4. **Audit-Logging**: Die Funktion aktiviert das Audit-Logging für Nextcloud.

5. **Syncthing-Konfiguration**: Es wird geprüft, ob der Syncthing-Ordner für Nextcloud existiert und ggf. erstellt.

6. **Gerät hinzufügen**: Die Funktion fügt ein Gerät (Raspberry Pi) zu Syncthing hinzu und teilt es mit dem Nextcloud-Ordner.

### Hauptskript

Das Hauptskript überprüft die Installation von Docker und Docker Compose, erstellt Verzeichnisse, lädt Konfigurationsdateien herunter, erstellt ein Docker-Netzwerk und führt dann die Funktion `check_nextcloud_status()` in einer Endlosschleife aus, um den Status von Nextcloud zu überprüfen.

- **Docker-Installation**: Überprüft und installiert Docker und Docker Compose falls erforderlich.

- **Verzeichnisse erstellen**: Erstellt Verzeichnisse für Nextcloud und Syncthing.

- **Konfigurationsdateien herunterladen**: Lädt Konfigurationsdateien (`docker-compose.yaml`, `.env`, `docker-entrypoint.sh`) für Docker und Nextcloud herunter.

- **Docker-Netzwerk erstellen**: Überprüft und erstellt ein Docker-Netzwerk namens "nextcloud", falls es nicht vorhanden ist.

- **Nextcloud-Installation überprüfen**: In einer Endlosschleife wird alle 5 Sekunden der Status von Nextcloud überprüft und entsprechend die Funktion `check_nextcloud_status()` aufgerufen, bis Nextcloud und Syncthing erfolgreich installiert sind.

## Ausführung

Das Skript kann auf einem Linux-System ausgeführt werden, um Nextcloud und Syncthing einzurichten. Es sollte mit Root-Berechtigungen ausgeführt werden, da es Docker-Operationen und Dateioperationen erfordert.

### Bilder
![Nextcloud](https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg)
![Syncthing](https://private-user-images.githubusercontent.com/127558095/300668895-0de2d4a3-3cbc-473c-a139-4e5f1e3dab9e.svg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDY1ODgyNDksIm5iZiI6MTcwNjU4Nzk0OSwicGF0aCI6Ii8xMjc1NTgwOTUvMzAwNjY4ODk1LTBkZTJkNGEzLTNjYmMtNDczYy1hMTM5LTRlNWYxZTNkYWI5ZS5zdmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwMTMwJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDEzMFQwNDEyMjlaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1kNzFiZTRjNzIzY2MxMjllZmRmNTA1NGRiOTc4MzhlNGRjNWRjZjNhOGViMmJiYjI0YzliNjUwMWIzMWQyMzM3JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZhY3Rvcl9pZD0wJmtleV9pZD0wJnJlcG9faWQ9MCJ9.dqNlDadVNBAc2y4zBjJp3YIceqEZ3xOQdsf8vKspCIA)

