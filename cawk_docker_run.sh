#!/bin/bash

# ---------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ---------------------------------------------------------------------
# this script is launched when cawk container is executed as described
# in the <Dockerfile> file
#
# requirement : <docker run> must be executed with <cawk-persistent-volume> :
# 	-v cawk-persistent-volume:/app/cawk/cawk-persistent-volume
#	(this is used to link cawk <persistent> directories to the volume)
#
# note : local tmp directory is used as an intermediary directory to copy 
#        data to cawk <persistent> volume (cawk-persistent-volume)
#
# authors : cedric llorens, florian heitz
# cawk docker version: 1.0
# ---------------------------------------------------------------------

# ------------------
# function used to copy cawk directories from tmp to cawk <persistent> volume
# ------------------
copy_with_log() {
    local source="$1"
    local destination="$2"
    local description="$3"
    local softlink="$4"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $description"
    if [ -d "$source" ] && [ "$(ls -A "$source" 2>/dev/null)" ]; then
        mkdir -p "$destination"
        cp -r "$source"/* "$destination"
        ln -s "$destination" "$softlink"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Copy completed with exit code: $?"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Source directory empty or doesn't exist: $source"
    fi
}

# ----------------
# function used to clean tmp 
# ----------------
cleanup_tmp() {
    local tmp_dir="$1"
    local description="$2"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $description"
    if [ -d "$tmp_dir" ]; then
        rm -rf "$tmp_dir"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleanup completed with exit code: $?"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Directory doesn't exist: $tmp_dir"
    fi
}

# ------------------
# Main 
# ------------------

# log
LOG_FILE="/app/cawk/cawk_docker_run.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# copy
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting copy cawk directories from tmp to persistent directory"
copy_with_log "/app/cawk/tmp/backup" "/app/cawk/cawk-persistent-volume/backup" "Copying backup files from /app/cawk/tmp/backup/* to /app/cawk/backup" "/app/cawk/backup"
copy_with_log "/app/cawk/tmp/database" "/app/cawk/cawk-persistent-volume/database" "Copying database files from /app/cawk/tmp/database/* to /app/cawk/database" "/app/cawk/database"
copy_with_log "/app/cawk/tmp/exceptions" "/app/cawk/cawk-persistent-volume/exceptions" "Copying exceptions from /app/cawk/tmp/exceptions/* to /app/cawk/exceptions" "/app/cawk/exceptions"
copy_with_log "/app/cawk/tmp/tests" "/app/cawk/cawk-persistent-volume/tests" "Copying tests from /app/cawk/tmp/tests/* to /app/cawk/tests" "/app/cawk/tests"
copy_with_log "/app/cawk/tmp/confs" "/app/cawk/cawk-persistent-volume/confs" "Copying configurations from /app/cawk/tmp/confs/* to /app/cawk/confs" "/app/cawk/confs"
copy_with_log "/app/cawk/tmp/logs" "/app/cawk/cawk-persistent-volume/logs" "Copying logs from /app/cawk/tmp/logs/* to /app/cawk/logs" "/app/cawk/logs"
copy_with_log "/app/cawk/tmp/reports" "/app/cawk/cawk-persistent-volume/reports" "Copying reports from /app/cawk/tmp/reports/* to /app/cawk/reports" "/app/cawk/reports"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] All copy operations completed"

# clean 
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting cleanup of tmp directories..."
cleanup_tmp "/app/cawk/tmp/backup" "Cleaning up /app/cawk/tmp/backup"
cleanup_tmp "/app/cawk/tmp/database" "Cleaning up /app/cawk/tmp/database"
cleanup_tmp "/app/cawk/tmp/exceptions" "Cleaning up /app/cawk/tmp/exceptions"
cleanup_tmp "/app/cawk/tmp/tests" "Cleaning up /app/cawk/tmp/tests"
cleanup_tmp "/app/cawk/tmp/confs" "Cleaning up /app/cawk/tmp/confs"
cleanup_tmp "/app/cawk/tmp/logs" "Cleaning up /app/cawk/tmp/logs"
cleanup_tmp "/app/cawk/tmp/reports" "Cleaning up /app/cawk/tmp/reports"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Container ready and waiting..."
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Logs saved in: $LOG_FILE"

# remain alive 
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Keeping container alive..."
while true; do
    sleep 3600
done
