#!/bin/bash
set -e

if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Init PostgreSQL @ $PGDATA"
    initdb -D "$PGDATA" --username=pguser
    echo "host all all all trust" >> "$PGDATA/pg_hba.conf"
    echo "listen_addresses='*'" >> "$PGDATA/postgresql.conf"
    echo "port = 5444" >> "$PGDATA/postgresql.conf"
fi

exec "$@"