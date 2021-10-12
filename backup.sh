#!/bin/bash

set -eo pipefail

if [ -z "$DATABASE_NAME" ]; then
    echo "DATABASE_NAME not set"
    exit 1
fi

if [ -z "$BACKUP_DIRECTORY" ]; then
    echo "BACKUP_DIRECTORY not set"
    exit 1
fi

if [ -z "$DATABASE_HOST" ]; then
    DATABASE_HOST=127.0.0.1
fi

if [ -z "$DATABASE_PORT" ]; then
    DATABASE_PORT=5432
fi

if [ -z "$DATABASE_USER" ]; then
    DATABASE_USER=postgres
fi

mkdir -p $BACKUP_DIRECTORY

PREFIX="${DATABASE_HOST}_${DATABASE_PORT}_${DATABASE_USER}_${DATABASE_NAME}"

if [ -n "$RETENTION" ]; then
    echo "Cleaning up old backups. Retention: $RETENTION"
    fd -t f -s --exact-depth 1 --changed-before "$RETENTION" $PREFIX $BACKUP_DIRECTORY -x rm -v {}
fi

FILE="$BACKUP_DIRECTORY/"$PREFIX"_"$(date -Iseconds)".psql.gz"
# assumes password is set somehome (env variables, .pgpass)
pg_dump -h $DATABASE_HOST -p $DATABASE_PORT -U $DATABASE_USER -C --no-password $DATABASE_NAME | gzip > "$FILE"
ls -al "$FILE"
echo "DONE"
