# docker-gdrive-to-s3

This repository is for a container that is really specific to my own use. The documentation is lacking, and its pretty messy.
I would not suggest it to be used in production. There is better alternative out there, see https://github.com/bcardiff/docker-rclone


|Environment Variables|Description|Default Value|
|---|---|---
|```AWS_S3_BUCKET```|The name of the S3 Bucket that will received the content of your GDrive. See notes for details about the required S3 bucket configuration|  |
|```CRON_SCHEDULE```|A crontab string to schedule the sync|```5 3 * * *```|
|```CUSTOM_RCLONE_GLOBAL_OPTS```|Used to give extra command line options to rclone|```--log-level INFO```|
|```RCLONE_CONF```|Used if you mount your own rclone configuration file into the container and need to provide the path to the file| |
|```AWS_ACCESS_KEY```|The AWS Access Key that can use the S3 bucket. Required when your not using your own configuration file | |
|```AWS_SECRET_KEY```|The AWS Secret Key that can use the S3 bucket. Required when your not using your own configuration file | |
|```GDRIVE_SCOPE```|If you need to change the scope of the GDrive source|```drive.readonly```|
|```GDRIVE_ROOTFLDR_ID```|Used if you want to override the default 'root' of the source| |
|```GDRIVE_SERVACCT_FILE```|If you want to use a Service Account File. This should be the path to the file inside the container| |
|```GDRIVE_TOKEN_JSON```|The JSON string containing the TOKEN received when you used the automatic web login| |
|```AWS_REGION```|To override the default AWS region|```us-east-1```|

## Examples

Using your own configuration for a direct sync (unscheduled):
```docker run --rm -it -v /home/theuser/.config/rclone:/config -e RCLONE_CONF='/config/rclone.conf' -e AWS_S3_BUCKET='my-awesome-gdrive-backup' gdrive-to-s3:latest sync-once```

Without config file for a direct sync (unscheduled):
```docker run --rm -it -e AWS_ACCESS_KEY='AN_AWS_ACCESS_KEY' -e AWS_SECRET_KEY='AN_AWS_SECRET_KEY' -e AWS_S3_BUCKET='my-awesome-gdrive-backup' -e GDRIVE_TOKEN_JSON='{"access_token":"A token string","token_type":"Bearer","refresh_token":"1/SoMeAlPhaDecImalStringStuff_SoMeAlPhaDecImal-SoMeAlPhaDecImal","expiry":"2018-05-15T15:06:19.227566895-04:00"}' gdrive-to-s3:latest sync-once```

Scheduled with service_account_file, restricted to a gdrive root folder id, custom rclone options and cron schedule :
```docker run --rm -it -v /The/Path/To/ServiceAccount.json:/root/serv_acct_file.json -e AWS_ACCESS_KEY='DEADBEEFDEADBEEFDEAD' -e AWS_SECRET_KEY='alphanumstringsecretkey1234' -e AWS_S3_BUCKET='my-awesome-gdrive-backup' -e GDRIVE_SERVACCT_FILE='/root/serv_acct_file.json' -e CUSTOM_RCLONE_GLOBAL_OPTS='--log-level INFO --dry-run' -e CRON_SCHEDULE='5 4 * * *' -e GDRIVE_ROOTFLDR_ID='alongstringofalphanumericcharactersasid' gdrive-to-s3:latest schedule```
