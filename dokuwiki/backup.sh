#!/bin/sh

# This script is used to backup data of an application in docker.
# The Docker compose file must define a service named "backup" that
# creates a backup file.
#
# This script must be present in the same directory as the compose.yaml file.
#
# Currently it is used to backup the dokuwiki application.

# Václav Brožík, 2024-03-07

BACKUP_FILE_PREFIX=dokuwiki_data_backup_
BACKUP_FILE_SUFFIX=.tbz

scp_upload_destination="nttlab_ubuntu-lts:~/backup"
compose_dir=$(cd "$(dirname "$0")" && pwd)
BACKUP_DIR="$compose_dir/backup"
service_to_stop=dokuwiki

# ---

export BACKUP_FILE_PREFIX
export BACKUP_FILE_SUFFIX
export BACKUP_DIR

mkdir -p "$BACKUP_DIR" || {
    echo "Could not create backup directory $BACKUP_DIR"
   exit 1
} 

if ! test -f "$compose_dir/compose.yaml" ; then
    echo "compose.yaml not found in $compose_dir"
    exit 1
fi

if ! cd "$compose_dir" ; then
    echo "Could not cd to $compose_dir"
    exit 1
fi

docker compose ps --services | grep -q "^$service_to_stop\$"
dokuwiki_was_running=$?

docker compose stop "$service_to_stop"
created_file_name=$(docker compose run --rm backup) && {
    rsync -avz "$BACKUP_DIR/$created_file_name" "$scp_upload_destination/"
}

if test "$dokuwiki_was_running" -eq 0 ; then
    docker compose start "$service_to_stop"
fi
