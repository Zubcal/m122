# Shell-Skript Dashboard Server (Grafana, Loki, Promtail)

# Inhaltsverzeichnis

1. [Shell-Skript-Erklärung](#shell-skript-erklärung)
   1. [Funktionen](#funktionen)
      - [`command_exists()`](#command_exists)
      - [`docker_installation()`](#docker_installation)
      - [`create_folders()`](#create_folders)
      - [`check_logs_existence()`](#check_logs_existence)
      - [`install_syncthing()`](#install_syncthing)
   2. [Hauptteil des Skripts](#hauptteil-des-skripts)
   3. [Grafana Dashboard](#grafana-dashboard)
   4. [Herunterladen der Konfigurationsdateien](#herunterladen-der-konfigurationsdateien)


Das vorliegende Shell-Skript hat den Zweck, verschiedene Aufgaben im Zusammenhang mit der Einrichtung und Installation von Docker, Docker Compose und Syncthing auf einem Linux-System zu automatisieren. Das Skript besteht aus mehreren Funktionen, die nacheinander ausgeführt werden.

## Funktionen

### `command_exists()`

Diese Funktion überprüft, ob ein bestimmter Befehl vorhanden ist, indem sie `command -v` verwendet.

### `docker_installation()`

Diese Funktion überprüft zunächst, ob Docker und Docker Compose bereits installiert sind. Falls nicht, werden sie installiert. Zuerst werden die Paketlisten aktualisiert und erforderliche Abhängigkeiten installiert. Anschließend wird Docker und Docker Compose heruntergeladen und installiert. Am Ende werden die installierten Versionen angezeigt.

### `create_folders()`

Diese Funktion erstellt verschiedene Ordner für die Verwendung mit Syncthing und anderen Scripts. Es werden Ordner für Syncthing, Docker, Grafana, Loki und Promtail erstellt. Außerdem werden Konfigurationsdateien für Loki, Promtail und Docker Compose heruntergeladen und in die entsprechenden Ordner kopiert.

### `check_logs_existence()`

Diese Funktion überprüft wiederholt, ob bestimmte Logdateien vorhanden sind, und wartet, bis sie vorhanden sind. Dies ist eine Wartezeit, bis bestimmte Aktionen ausgeführt werden können.

### `install_syncthing()`

Diese Funktion installiert Syncthing mit Docker. Zuerst wird ein Docker-Container für Syncthing gestartet. Dann wird die Geräte-ID von Syncthing abgerufen und angezeigt. Der Benutzer wird aufgefordert, die Geräte-ID des Überwachungs-Syncthing einzugeben, und die Eingabe wird überprüft. Danach wird das Überwachungsgerät zu Syncthing hinzugefügt. Anschließend werden Logs überprüft, Docker Compose gestartet und abschließend wird die Erreichbarkeit des Grafana-Dashboards angezeigt.

## Hauptteil des Skripts

Im Hauptteil des Skripts werden die oben genannten Funktionen in folgender Reihenfolge aufgerufen:

1. Installation von Docker und Docker Compose (`docker_installation`)
2. Erstellen von Ordnern für Syncthing und Scripts (`create_folders`)
3. Installieren von Syncthing mit Docker Compose (`install_syncthing`)

Die Ausführung des gesamten Skripts erfolgt durch Aufruf des Hauptteils am Ende des Skripts.

## Grafana Dashboard

Hier ist ein Screenshot des Grafana-Dashboards das ich zusammengebaut habe: 
![Grafana Dashboard Screenshot](https://github.com/Zubcal/m122/assets/127558095/eeeac073-f25e-4c22-b2a2-7a77096e6461)
(Pfad/zum/Screenshot.png)

## Herunterladen der Konfigurationsdateien

Die Konfigurationsdateien für Loki und Promtail werden heruntergeladen, um sicherzustellen, dass die Docker-Container mit den richtigen Konfigurationen gestartet werden können. Diese Dateien enthalten Einstellungen und Konfigurationen für Loki, das für das Sammeln, Speichern und Abfragen von Protokollen verwendet wird, sowie für Promtail, das für das Sammeln und Weiterleiten von Protokollen an Loki zuständig ist. ohne das Herunterladen und dieser Konfigurationsdateien wird werder Promtail noch loki funtkionieren.

