![postgresql-icon](https://github.com/Zubcal/m122/assets/127558095/a971a701-7ca6-4304-898b-dc67a559c23d)
# Nextcloud Log Monitoring und Visualisierung

## Übersicht

Dieses Projekt zielt darauf ab, die Logs von Nextcloud zu erfassen, sie mit Syncthing mit einem anderen Gerät namens "Monitoring-Server" zu synchronisieren, die Logs zu formatieren und sie dann an Grafana weiterzuleiten, um sie in einem Dashboard anzuzeigen. 

## Technologien

### Docker & Docker-Compose

Docker wird in diesem Projekt verwendet, um die Anwendungen in Containern zu isolieren und zu betreiben. Docker-Compose wird verwendet, um die Container zu definieren und zu verwalten.
![Docker](https://github.com/Zubcal/m122/assets/127558095/21a40137-1250-4a28-9c04-bd52633352a3)

![Docker-Compose](https://github.com/Zubcal/m122/assets/127558095/f95d0b91-632e-462d-9619-d0fdb76586a6)


### Nextcloud

Nextcloud ist eine Open-Source-Software für die Speicherung von Dateien, die auch Funktionen wie Kalender, Kontakte und mehr bietet.
![Nextcloud](https://camo.githubusercontent.com/97d7856c195003d99e539a03159e60212f1312fbc196f0bde298ddffa06c31c5/68747470733a2f2f75706c6f61642e77696b696d656469612e6f72672f77696b6970656469612f636f6d6d6f6e732f362f36302f4e657874636c6f75645f4c6f676f2e737667)

### PostgreSQL ❤️

PostgreSQL wird als Datenbank verwendet, um die Nextcloud-Daten zu speichern.
![PostgreSQL](postgresql.png)



### Ubuntu

Ubuntu wird als Betriebssystem für alle Hostmaschine verwendet, auf der die Docker-Container ausgeführt werden. (getestet)
![Ubuntu](ubuntu.png)

### Syncthing

Syncthing ist ein Open-Source-Tool für die Dateisynchronisierung zwischen Geräten.

![Syncthing]([syncthing.png](https://private-user-images.githubusercontent.com/127558095/300668895-0de2d4a3-3cbc-473c-a139-4e5f1e3dab9e.svg?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDY1ODgyMjIsIm5iZiI6MTcwNjU4NzkyMiwicGF0aCI6Ii8xMjc1NTgwOTUvMzAwNjY4ODk1LTBkZTJkNGEzLTNjYmMtNDczYy1hMTM5LTRlNWYxZTNkYWI5ZS5zdmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjQwMTMwJTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI0MDEzMFQwNDEyMDJaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT0zZjdjYjY5NTJhNWY1ZTAzZDI1NmQ4ZGRkNDI0MDkyMTQxNjg4OGYzZjBjZTcwZDU1YTk3MTQ5YTA5MzhjMzdjJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCZhY3Rvcl9pZD0wJmtleV9pZD0wJnJlcG9faWQ9MCJ9.xZD2Vs6sSkSkP2AY0rw_1pjPSKltIOMD8h49lPzZ7Dc))
### jq

jq ist ein CMD Tool für die Datenmanipulation in JSON-Format. (nextcloud schreibt die logs in Json Format)
![jq](jq.png)

### Promtail, Loki und Grafana

Promtail ist ein Agent für das Loggen von Anwendungen und sendet die Protokolle an Loki, Promtail soll ein horizontales, hochverfügbares und skalierbares Protokollaggregations- und -speicherungssystem sein. Grafana wird verwendet, um die Protokolle zu visualisieren und in Dashboards darzustellen.

![Promtail](promtail.png)
![Loki](loki.png)
![Grafana](grafana.png)


## Architektur

![Architekturdiagramm](architektur.png)

Die Architektur umfasst folgende Schritte:

1. Nextcloud generiert Logs.
2. Syncthing synchronisiert die Logs mit dem Monitoring-Server.
3. Der Monitoring-Server formatiert die Logs & leitet sie an Promtail weiter
5. Promtail sammelt die Logs und leitet sie an Loki weiter.
6. Grafana liest die Logs aus Loki und visualisiert sie in Dashboards.

