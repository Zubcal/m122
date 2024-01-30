
# Nextcloud Log Monitoring und Visualisierung

## Übersicht

Dieses Projekt zielt darauf ab, die Logs von Nextcloud zu erfassen, sie mit Syncthing mit einem anderen Gerät namens "Monitoring-Server" zu synchronisieren, die Logs zu formatieren und sie dann an Grafana weiterzuleiten, um sie in einem Dashboard anzuzeigen. 

## Technologien

### Docker & Docker-Compose

Docker wird in diesem Projekt verwendet, um die Anwendungen in Containern zu isolieren und zu betreiben. Docker-Compose wird verwendet, um die Container zu definieren und zu verwalten.



### Nextcloud

Nextcloud ist eine Open-Source-Software für die Speicherung von Dateien, die auch Funktionen wie Kalender, Kontakte und mehr bietet.

![Nextcloud](https://upload.wikimedia.org/wikipedia/commons/6/60/Nextcloud_Logo.svg)


### PostgreSQL ❤️

PostgreSQL wird als Datenbank verwendet, um die Nextcloud-Daten zu speichern.

![postgresql-icon](https://github.com/Zubcal/m122/assets/127558095/a971a701-7ca6-4304-898b-dc67a559c23d)



### Ubuntu

Ubuntu wird als Betriebssystem für alle Hostmaschine verwendet, auf der die Docker-Container ausgeführt werden. (getestet)


### Syncthing

Syncthing ist ein Open-Source-Tool für die Dateisynchronisierung zwischen Geräten.


### jq

jq ist ein CMD Tool für die Datenmanipulation in JSON-Format. (nextcloud schreibt die logs in Json Format)
![jq](jq.png)

### Promtail, Loki und Grafana

Promtail ist ein Agent für das Loggen von Anwendungen und sendet die Protokolle an Loki, Promtail soll ein horizontales, hochverfügbares und skalierbares Protokollaggregations- und -speicherungssystem sein. Grafana wird verwendet, um die Protokolle zu visualisieren und in Dashboards darzustellen.



## Architektur

![Architekturdiagramm](architektur.png)

Die Architektur umfasst folgende Schritte:

1. Nextcloud generiert Logs.
2. Syncthing synchronisiert die Logs mit dem Monitoring-Server.
3. Der Monitoring-Server formatiert die Logs & leitet sie an Promtail weiter
5. Promtail sammelt die Logs und leitet sie an Loki weiter.
6. Grafana liest die Logs aus Loki und visualisiert sie in Dashboards.

