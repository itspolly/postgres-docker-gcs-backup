# Backup Postgres Docker containers to Google Cloud Storage
**Inspired by [postgres-backup-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3)**

This docker image allows for scheduled backups of a postgres docker container to a Google Cloud Storage bucket.

## Usage

### Environment variables
| Variable                | Description                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------|
| `POSTGRES_DATABASE`     | The name of the database to backup.                                                                            |
| `POSTGRES_HOST`         | The host of the database to backup.                                                                            |
| `POSTGRES_PORT`         | The port of the database to backup.  **Default:** 5432                                                         |
| `POSTGRES_USER`         | The username of the backup user.                                                                               |
| `POSTGRES_PASSWORD`     | The password of the backup user.                                                                               |
| `POSTGRES_EXTRA_OPTS`   | Any additional options you wish to pass to `pg_dump`. **Default:** `''`                                        |
| `GCLOUD_KEYFILE_BASE64` | The GCP service account's credential file, in base64. See below for recommendations regarding this.            |
| `GCLOUD_PROJECT_ID`     | The Project ID which the bucket you wish to backup to is in.                                                   |
| `GCS_BACKUP_BUCKET`     | The `gs://` path to the storage bucket you wish to backup to.                                                  |
| `SCHEDULE`              | How often you wish the backup to occur. See [Scheduling](#Scheduling) for more information on formatting this. |

### Scheduling

More information on the schedule format can be found [here](https://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

### Google Cloud Service Account

We reccomend creating a new, write-only service account to the storage bucket you wish to backup to.