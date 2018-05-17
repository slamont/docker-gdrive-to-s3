#!/bin/bash

set -e

log() {
    echo "[$(date +"%Y-%m-%d+%T")]: $*"
}

usage() {
cat << EOF
Usage: ${0##*/} ...
    -h  Display an help message
    -b <S3 Bucket name> Specify the S3 bucket name used for destination 

Environment Variables
---------------------
EOF
}

rclone_exec="rclone ${CUSTOM_RCLONE_GLOBAL_OPTS} "

get_source_name() {
  local source_id=
  source_id=$($rclone_exec listremotes -l | grep drive | awk -F: '{print $1}')
  echo "${source_id}:"
}

get_destination_name() {
  local destination_id=
  destination_id=$($rclone_exec listremotes -l | grep s3 | awk -F: '{print $1}')
  echo "${destination_id}:"
}

execute_sync() {
  local source_name=$(get_source_name)
  local destination_name=$(get_destination_name)
  local bucket_name=${1:?"Bucket name is required"}
  $rclone_exec sync ${CUSTOM_RCLONE_SYNC_OPTS} ${source_name} ${destination_name}${bucket_name}
}

[ $# -eq 0 ] && { usage ; exit 1; }

log "================================"
log "Google Drive Sync to S3 Bucket  "
log "================================"
log
while getopts ":b:" OPTION ; do
  case "$OPTION" in
    b )
      log
      log "Using [${OPTARG}] for S3 Bucket Name"
      execute_sync ${OPTARG}
      log
      ;;
    \? )
      log "Display an help message"
      usage
      ;;
    * )
      log "An Error occured! Try reviewing your arguments."
      usage
      exit 255
      ;;
  esac
done
