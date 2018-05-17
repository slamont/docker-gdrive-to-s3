#!/bin/bash

set -e

: "${AWS_S3_BUCKET:?"AWS_S3_BUCKET env variable is required"}"
CRON_SCHEDULE=${CRON_SCHEDULE:-5 3 * * *}
CUSTOM_RCLONE_GLOBAL_OPTS=${CUSTOM_RCLONE_GLOBAL_OPTS:-"--log-level INFO "}

if [ -z "${RCLONE_CONF}" ]; then
  echo "No rclone configuration provided, configuring it..."

  : "${AWS_ACCESS_KEY:?"AWS_ACCESS_KEY env variable is required"}"
  : "${AWS_SECRET_KEY:?"AWS_SECRET_KEY env variable is required"}"

  sed 's/^\s*//' > /root/.config/rclone/rclone.conf << EOF
    [google-drive]
    type = drive
    client_id = 
    client_secret = 
    scope = ${GDRIVE_SCOPE:-"drive.readonly"}
    root_folder_id = ${GDRIVE_ROOTFLDR_ID}
    service_account_file = ${GDRIVE_SERVACCT_FILE}
    token = ${GDRIVE_TOKEN_JSON}
    team_drive = 

    [s3-bucket]
    type = s3
    provider = AWS
    env_auth = false
    access_key_id = ${AWS_ACCESS_KEY}
    secret_access_key = ${AWS_SECRET_KEY}
    region = ${AWS_REGION:-"us-east-1"}
    endpoint = 
    location_constraint = 
    acl = private
    server_side_encryption = AES256
    storage_class = 
EOF
else
  CUSTOM_RCLONE_GLOBAL_OPTS="${CUSTOM_RCLONE_GLOBAL_OPTS} --config ${RCLONE_CONF}"
fi

export CUSTOM_RCLONE_GLOBAL_OPTS

case $1 in 
  sync-once)
    exec /usr/bin/sync.sh -b ${AWS_S3_BUCKET}
    ;;

  schedule)
    echo "Scheduling Sync cron:$CRON_SCHEDULE"
    LOGFIFO='/var/run/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
      mkfifo "$LOGFIFO"
    fi
    CRON_ENV=$(printenv | grep -e '^CUSTOM_' -e '^PATH')
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /usr/bin/sync.sh -b ${AWS_S3_BUCKET} > $LOGFIFO 2>&1" | crontab -
    cron
    tail -f "$LOGFIFO"
    ;;
  *)
    echo "Entrypoint could not understand specified operation. Delegating..."
    exec "$@"
    ;;
esac

