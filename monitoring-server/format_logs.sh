#!/bin/bash

# Pfade
nextcloud_audit_log="/opt/M122/syncthing/nextcloud-logs/nextcloud/audit.log"
nextcloud_nextcloud_log="/opt/M122/syncthing/nextcloud-logs/nextcloud/nextcloud.log"
formatted_logs_path="/opt/M122/syncthing/"

# Funktion zur Formatierung der Log-Levels
format_log_levels() {
    awk 'BEGIN { 
        levels[0]="debug"; 
        levels[1]="info"; 
        levels[2]="warning"; 
        levels[3]="error"; 
        levels[4]="critical";
    } 
    { 
        for (i=0; i<=4; i++) 
            gsub("\"level\": " i ",", "\"level\": \"" levels[i] "\"", $0); 
        print 
    }' "$1" > "${formatted_logs_path}/formatted_$(basename "$1")"
}

# Formatierung der Log-Levels für beide Log-Dateien
format_log_levels "$nextcloud_audit_log"
format_log_levels "$nextcloud_nextcloud_log"
