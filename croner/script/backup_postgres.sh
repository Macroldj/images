#!/bin/bash

# PostgreSQL Database Backup Script
# This script creates backups of PostgreSQL databases and manages retention

# Configuration variables
PG_HOST="localhost"
PG_PORT="5432"
PG_USER="postgres"
PG_PASSWORD="" # For security, consider using PGPASSFILE instead
PG_DATABASES="all" # Comma-separated list of databases or "all"
BACKUP_DIR="/data/backup/postgres"
RETENTION_DAYS=7
DATESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="/var/log/postgres_backup.log"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Log function
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a "$LOG_FILE"
}

# Check if pg_dump is available
if ! command -v pg_dump &> /dev/null; then
    log "ERROR: pg_dump command not found. Please install PostgreSQL client tools."
    exit 1

fi

# Set PGPASSWORD environment variable if password is provided
if [ -n "$PG_PASSWORD" ]; then
    export PGPASSWORD="$PG_PASSWORD"
fi

# Get list of databases
if [ "$PG_DATABASES" = "all" ]; then
    log "Getting list of all databases..."
    PG_DATABASES=$(psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres'" | tr -d ' ')
    if [ $? -ne 0 ]; then
        log "ERROR: Failed to get database list"
        exit 1
    fi
else
    # Convert comma-separated list to space-separated
    PG_DATABASES=$(echo "$PG_DATABASES" | tr ',' ' ')
fi

# Backup each database
for DB in $PG_DATABASES; do
    BACKUP_FILE="$BACKUP_DIR/${DB}_${DATESTAMP}.sql.gz"
    log "Backing up database: $DB to $BACKUP_FILE"
    
    # Perform the backup
    # docker exec -it standalone_teable-db_1 pg_dump -U example -d example -F c > /data/backup/test.sql
    # psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$TARGET_DB" -f "$BACKUP_FILE"
    # docker exec -it standalone_teable-db_1 pg_dump psql -U example -d example1 -f /data/backup/test.sql
    pg_dump -h "$PG_HOST" -p "$PG_PORT" -U "$PG_USER" -d "$DB" -F c | gzip > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        log "SUCCESS: Database $DB backup completed"
        # Set appropriate permissions
        chmod 600 "$BACKUP_FILE"
    else
        log "ERROR: Database $DB backup failed"
    fi
done

# Clean up old backups
log "Cleaning up backups older than $RETENTION_DAYS days"
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -delete

# Clean up environment
unset PGPASSWORD

log "Backup process completed"

exit 0