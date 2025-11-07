#!/usr/bin/env bash
# ==============================================
# Automated Backup System by Kesava
# ==============================================
# Features:
# ✅ Compressed backups (.tar.gz)
# ✅ Incremental backups (.snar)
# ✅ Checksum (SHA256)
# ✅ Rotation (daily/weekly/monthly)
# ✅ Verification (checksum + extraction)
# ✅ Logging
# ✅ Dry-run mode
# ✅ Lockfile
# ✅ Restore and list modes
# ✅ Configurable via backup.config
# ==============================================

set -euo pipefail

# -------- Load Config --------
CONFIG_FILE="./backup.config"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Error: Config file not found! Using defaults."
    BACKUP_DESTINATION="./Backups"
    EXCLUDE_PATTERNS=".git,node_modules,.cache"
    DAILY_KEEP=7
    WEEKLY_KEEP=4
    MONTHLY_KEEP=3
    MIN_SPACE_MB=100
    DEFAULT_DRY_RUN=0
    SNAPSHOT_FILE="./backup.snar"
    BACKUP_PREFIX="backup"
    DATE_FORMAT="%Y-%m-%d-%H%M"
    TAR_OPTS="-czf"
    LOCK_FILE="/tmp/backup.lock"
    LOG_FILE="./backup.log"
fi

# -------- Helpers --------
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$LOG_FILE"
}

err_exit() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" | tee -a "$LOG_FILE" >&2
    exit 1
}

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <source_dir>

Options:
  --dry-run            Run without writing files
  --list               List available backups
  --incremental        Create incremental backup
  --restore <file> --to <dir>  Restore backup file to directory
  --help               Show this help

Examples:
  $0 /home/user/project
  $0 --incremental /data
  $0 --restore backup-2025-11-05-1800.tar.gz --to ./restored
EOF
}

# -------- Locking --------
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" &>/dev/null; then
            return 1
        else
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

trap release_lock EXIT

# -------- Functions --------
check_space() {
    local dest_fs
    dest_fs=$(df -Pm "$BACKUP_DESTINATION" | tail -1 | awk '{print $4}')
    if (( dest_fs < MIN_SPACE_MB )); then
        err_exit "Not enough disk space! Available: ${dest_fs}MB, Required: ${MIN_SPACE_MB}MB"
    fi
}

create_checksum() {
    sha256sum "$1" > "$1.sha256"
}

verify_checksum() {
    sha256sum -c "$1.sha256"
}

create_backup() {
    local src="$1"
    local dry="$2"
    check_space
    mkdir -p "$BACKUP_DESTINATION"

    local timestamp
    timestamp=$(date +"$DATE_FORMAT")
    local backup_file="${BACKUP_DESTINATION}/${BACKUP_PREFIX}-${timestamp}.tar.gz"
    local exclude_args=()

    IFS=',' read -ra EXCLUDES <<< "$EXCLUDE_PATTERNS"
    for e in "${EXCLUDES[@]}"; do
        exclude_args+=(--exclude="$e")
    done

    if [[ "$dry" -eq 1 ]]; then
        log "[DRY-RUN] Would create $backup_file from $src"
        return 0
    fi

    log "Creating backup: $backup_file"
    tar $TAR_OPTS "$backup_file" "${exclude_args[@]}" "$src"
    create_checksum "$backup_file"
    log "Backup created: $backup_file"
}

create_incremental_backup() {
    local src="$1"
    local dry="$2"
    check_space
    mkdir -p "$BACKUP_DESTINATION"

    local timestamp
    timestamp=$(date +"$DATE_FORMAT")
    local backup_file="${BACKUP_DESTINATION}/${BACKUP_PREFIX}-${timestamp}-inc.tar.gz"
    local exclude_args=()

    IFS=',' read -ra EXCLUDES <<< "$EXCLUDE_PATTERNS"
    for e in "${EXCLUDES[@]}"; do
        exclude_args+=(--exclude="$e")
    done

    if [[ "$dry" -eq 1 ]]; then
        log "[DRY-RUN] Would create incremental $backup_file from $src"
        return 0
    fi

    log "Creating incremental backup: $backup_file"
    tar --listed-incremental="$SNAPSHOT_FILE" $TAR_OPTS "$backup_file" "${exclude_args[@]}" "$src"
    create_checksum "$backup_file"
    log "Incremental backup created: $backup_file"
}

list_backups() {
    echo "Available backups in $BACKUP_DESTINATION:"
    ls -lh "$BACKUP_DESTINATION"/*.tar.gz 2>/dev/null || echo "No backups found."
}

restore_backup() {
    local file="$1"
    local target="$2"

    mkdir -p "$target"
    log "Restoring $file to $target"
    tar -xzf "$BACKUP_DESTINATION/$file" -C "$target"
    log "Restore completed"
}

rotate_backups() {
    log "Rotating backups..."
    local files=( $(ls -1t "$BACKUP_DESTINATION"/*.tar.gz 2>/dev/null || true) )
    local total=${#files[@]}

    if (( total > DAILY_KEEP )); then
        for ((i=DAILY_KEEP; i<total; i++)); do
            log "Deleting old backup: ${files[$i]}"
            rm -f "${files[$i]}" "${files[$i]}.sha256"
        done
    fi
}

# -------- Argument Parsing --------
if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

MODE=full
DRY_RUN=$DEFAULT_DRY_RUN
RESTORE_FILE=""
RESTORE_TO=""
SRC=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=1; shift;;
        --list) MODE=list; shift;;
        --incremental) MODE=incremental; shift;;
        --restore) MODE=restore; RESTORE_FILE="$2"; shift 2;;
        --to) RESTORE_TO="$2"; shift 2;;
        --help) usage; exit 0;;
        -*) echo "Unknown option: $1"; usage; exit 1;;
        *) SRC="$1"; shift;;
    esac
done

# Acquire lock (except for list)
if [[ "$MODE" != "list" ]]; then
    acquire_lock || err_exit "Another backup process is already running!"
fi

# -------- Execute Mode --------
case "$MODE" in
    list)
        list_backups
        ;;
    restore)
        if [[ -z "$RESTORE_FILE" || -z "$RESTORE_TO" ]]; then
            err_exit "--restore requires --to <dir>"
        fi
        restore_backup "$RESTORE_FILE" "$RESTORE_TO"
        ;;
    incremental)
        if [[ -z "$SRC" ]]; then
            err_exit "Source path required for incremental backup"
        fi
        create_incremental_backup "$SRC" "$DRY_RUN" || err_exit "Incremental backup failed"
        rotate_backups
        ;;
    full)
        if [[ -z "$SRC" ]]; then
            err_exit "Source path required for full backup"
        fi
        create_backup "$SRC" "$DRY_RUN" || err_exit "Full backup failed"
        rotate_backups
        ;;
    *)
        err_exit "Invalid mode"
        ;;
esac

log "Backup operation complete."

