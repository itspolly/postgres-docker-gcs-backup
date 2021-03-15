# Backup Postgres Docker containers to Google Cloud Storage
**A fork of [postgres-docker-gcs-backup](https://github.com/jamiebishop/postgres-docker-gcs-backup)**

**Inspired by [postgres-backup-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3)**

This docker image allows for scheduled backups of a postgres docker container to a Google Cloud Storage bucket.

## Usage

This image is published on the [fabric-registry](https://console.cloud.google.com/gcr/images/fabric-registry/GLOBAL/tools?project=fabric-registry).

### Environment variables
| Variable                | Description                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------|
| `POSTGRES_DATABASE`     | The name of the database to backup. If empty - dumping all databases (using `pg_dumpall`).                     |
| `POSTGRES_HOST`         | The host of the database to backup.                                                                            |
| `POSTGRES_PORT`         | The port of the database to backup.  **Default:** 5432                                                         |
| `POSTGRES_USER`         | The username of the backup user.                                                                               |
| `POSTGRES_PASSWORD`     | The password of the backup user.                                                                               |
| `POSTGRES_EXTRA_OPTS`   | Any additional options you wish to pass to `pg_dump`/`pg_dumpall`. **Default:** `''`                           |
| `GCLOUD_KEYFILE_BASE64` | The GCP service account's credential file, in base64. See below for recommendations regarding this.            |
| `GCLOUD_KEYFILE`        | The path to GCP service account's credential JSON file. Fallback if `GCLOUD_KEYFILE_BASE64` is not given.      |
| `GCLOUD_PROJECT_ID`     | The Project ID which the bucket you wish to backup to is in.                                                   |
| `GCS_BACKUP_BUCKET`     | The `gs://` path to the storage bucket you wish to backup to.                                                  |
| `SCHEDULE`              | How often you wish the backup to occur. See [Scheduling](#Scheduling) for more information on formatting this. |

### Scheduling

More information on the schedule format can be found [here](https://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

### Google Cloud Service Account

We recommend creating a new, write-only service account to the storage bucket you wish to backup to (with the `storage.objects.list` and `storage.objects.create` permissions).

### Docker Compose

Below is a sample Docker Compose service.

```yaml
dbbackups:
    image: "gcr.io/fabric-registry/tools/postgres-docker-gcs-backup:latest"
    depends_on:
      - database
    environment:
      SCHEDULE: "@every 6h"
      POSTGRES_HOST: "database"
      POSTGRES_DATABASE: "SomeDatabase"
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      GCLOUD_KEYFILE_BASE64: "BASE64_PROJECT_KEYFILE_HERE"
      GCLOUD_PROJECT_ID: "hello-world"
      GCS_BACKUP_BUCKET: "gs://my-backup-bucket-name"
```

**Note:** the backups on GCP are stored in year/month/day folders. You may add a prefix (e.g., `FABRIC_NAMESPACE`) by adding a suffix to `GCS_BACKUP_BUCKET`.