#! /bin/sh

set -e
set -o pipefail



# Environment checks
if [ "${POSTGRES_HOST}" = "**None**" ]; then
  if [ -n "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
    POSTGRES_HOST=$POSTGRES_PORT_5432_TCP_ADDR
    POSTGRES_PORT=$POSTGRES_PORT_5432_TCP_PORT
  else
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
  fi
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable."
  exit 1
fi

if [ "${GCLOUD_KEYFILE_BASE64}" = "**None**" -a "${GCLOUD_KEYFILE}" = "**None**" ]; then
  echo "You need to set either GCLOUD_KEYFILE_BASE64 or GCLOUD_KEYFILE environment variable."
  exit 1
fi

if [ "${GCLOUD_PROJECT_ID}" = "**None**" ]; then
  echo "You need to set the GCLOUD_PROJECT_ID environment variable."
  exit 1
fi

if [ "${GCS_BACKUP_BUCKET}" = "**None**" ]; then
  echo "You need to set the GCS_BACKUP_BUCKET environment variable."
  exit 1
fi



# Google Cloud Auth
echo "Authenticating to Google Cloud..."
if [ "${GCLOUD_KEYFILE_BASE64}" != "**None**" ]; then
  echo $GCLOUD_KEYFILE_BASE64 | base64 -d > $GCLOUD_KEYFILE
fi
gcloud auth activate-service-account --key-file $GCLOUD_KEYFILE --project "$GCLOUD_PROJECT_ID" -q



# Postgres dumping
DATE=`date +"%Y_%m_%d_%H-%M-%S"`
FILENAME="${DATE}.sql.gz"
export PGPASSWORD=$POSTGRES_PASSWORD
POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"

if [ "${POSTGRES_DATABASE}" = "**None**" ]; then
  echo "Creating dump of all databases from ${POSTGRES_HOST}..."
  pg_dumpall $POSTGRES_HOST_OPTS | gzip > $FILENAME
else
  echo "Creating dump of ${POSTGRES_DATABASE} database from ${POSTGRES_HOST}..."
  pg_dump $POSTGRES_HOST_OPTS $POSTGRES_DATABASE | gzip > $FILENAME
fi



# Upload to GCS
echo "Uploading dump to $GCS_BACKUP_BUCKET..."
gsutil cp $FILENAME $GCS_BACKUP_BUCKET/$(echo $FILENAME | sed 's%_%/%g')
rm $FILENAME # delete old file
echo "SQL backup uploaded successfully."