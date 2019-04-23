#! /bin/sh

set -e


if [ "${SCHEDULE}" = "**None**" ]; then
  echo "You must set a backup schedule."
  exit 1
fi

exec go-cron "$SCHEDULE" /bin/sh backup.sh
