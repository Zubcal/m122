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

# E-Mail-Konfiguration
TO_EMAIL=""
FROM_EMAIL=""
SUBJECT="Log-Einträge mit Warning-Level oder höher"

# Funktion zum Versenden von E-Mails
# Funktion zum Versenden von E-Mails
send_email() {
    local log_entry="$1"

    echo -e "Achtung: Das Log-Level 'warning/error/critical' wurde in den formatierten Log-Dateien gefunden. Hier ist der relevante Log-Eintrag:\n" > email_body.txt
    echo -e "$log_entry" >> email_body.txt

    # E-Mail senden
    mail -s "$SUBJECT" -a "From: $FROM_EMAIL" "$TO_EMAIL" < email_body.txt

    # Temporäre Datei löschen
    rm email_body.txt
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
}

# Funktion zur Verarbeitung von Log-Einträgen
process_logs() {
    local log_file="$1"
    local matching_entries=$(jq -c '. | select(.level == "warning" or .level == "error" or .level == "critical")' "$log_file")

    # Nur die neuesten Einträge nehmen
    latest_entry=$(echo "$matching_entries" | tail -n 1)

    if [ -n "$latest_entry" ]; then
        send_email "$latest_entry"
    fi
}

# Funktion für die Verarbeitung von Änderungen in Echtzeit
watch_logs() {
    while true; do
        inotifywait -e modify "$NEXTCLOUD_AUDIT_LOG" "$NEXTCLOUD_NEXTCLOUD_LOG"
        format_log_levels "$NEXTCLOUD_AUDIT_LOG"
        format_log_levels "$NEXTCLOUD_NEXTCLOUD_LOG"
        process_logs "${FORMATTED_LOGS_PATH}/formatted_$(basename "$NEXTCLOUD_AUDIT_LOG")"
        process_logs "${FORMATTED_LOGS_PATH}/formatted_$(basename "$NEXTCLOUD_NEXTCLOUD_LOG")"
    done
}

# Log-Levels für beide Log-Dateien formatieren
format_log_levels "$NEXTCLOUD_AUDIT_LOG"
format_log_levels "$NEXTCLOUD_NEXTCLOUD_LOG"

# Log-Dateien in Echtzeit überwachen
watch_logs
