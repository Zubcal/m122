#!/bin/bash

# Pfade
NEXTCLOUD_AUDIT_LOG="/opt/M122/syncthing/nextcloud-logs/nextcloud/audit.log"
NEXTCLOUD_NEXTCLOUD_LOG="/opt/M122/syncthing/nextcloud-logs/nextcloud/nextcloud.log"
FORMATTED_LOGS_PATH="/opt/M122/syncthing/"


# Fehlerbehandlung für Log-Dateien hinzufügen
if [ ! -f "$NEXTCLOUD_AUDIT_LOG" ] || [ ! -r "$NEXTCLOUD_AUDIT_LOG" ]; then
    echo "Fehler: Die Audit-Log-Datei existiert nicht oder ist nicht lesbar."
    exit 1
fi

if [ ! -f "$NEXTCLOUD_NEXTCLOUD_LOG" ] || [ ! -r "$NEXTCLOUD_NEXTCLOUD_LOG" ]; then
    echo "Fehler: Die Nextcloud-Log-Datei existiert nicht oder ist nicht lesbar."
    exit 1
fi

if [ -e "$FORMATTED_AUDIT_LOG" ] || [ -e "$FORMATTED_NEXTCLOUD_LOG" ]; then
    echo "Fehler: Eine oder beide formatierten Log-Dateien existieren bereits."
    exit 1
fi

# Funktion zum Versenden von E-Mails
send_email() {
    echo "Achtung: Das Wort 'warning' wurde in den formatierten Log-Dateien gefunden." | mail -s "Betreff der E-Mail" -a "From: binthenvansinthen@smart-mail.de" "zubeyrcali202@gmail.com"
}

# Funktion zur Formatierung der Log-Levels
format_log_levels() {
    awk 'BEGIN {
        levels[0]="\"debug\"";
        levels[1]="\"info\"";
        levels[2]="\"warning\"";
        levels[3]="\"error\"";
        levels[4]="\"critical\"";
    }
    {
        for (i=0; i<=4; i++)
            gsub("\"level\":[[:space:]]*" i ",", "\"level\": " levels[i] ",", $0);
        print
    }' "$1" | jq '.' > "${FORMATTED_LOGS_PATH}/formatted_$(basename "$1")"
    # Prüfen, ob das Wort "warning" in der formatierten Datei gefunden wird
    if grep -q "warning" "${FORMATTED_LOGS_PATH}/formatted_$(basename "$1")"; then
        send_email
    fi
}

# Funktion für die Verarbeitung von Änderungen in Echtzeit
watch_logs() {
    while true; do
        inotifywait -e modify "$NEXTCLOUD_AUDIT_LOG" "$NEXTCLOUD_NEXTCLOUD_LOG"
        format_log_levels "$NEXTCLOUD_AUDIT_LOG"
        format_log_levels "$NEXTCLOUD_NEXTCLOUD_LOG"
    done
}


# Log-Levels für beide Log-Dateien formatieren
format_log_levels "$NEXTCLOUD_AUDIT_LOG"
format_log_levels "$NEXTCLOUD_NEXTCLOUD_LOG"

# Log-Dateien in Echtzeit überwachen
watch_logs
