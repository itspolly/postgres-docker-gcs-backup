#! /bin/sh

# Exit if a command fails
set -e

# Update
apk update

# Install pg_dump
apk add --no-cache postgresql-client=13.2-r0

# Install go-chron
apk add curl
curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron
apk del curl

# Cleanup
rm -rf /var/cache/apk/*