#! /bin/sh

set -e


if [ "${SCHEDULE}" = "**None**" ]; then
  echo "You must set a backup schedule."
  exit 1
fi

echo "Performing an immediate backup..."
exec /bin/sh backup.sh # perform an immediate backup
exec go-cron "$SCHEDULE" /bin/sh backup.sh
