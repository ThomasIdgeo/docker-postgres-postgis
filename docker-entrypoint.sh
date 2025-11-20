#!/bin/bash
set -e

# ----------------------------------------------------- #
# Sécurité : interdiction de lancer PostgreSQL en root  #
# ----------------------------------------------------- #
if [ "$(id -u)" = "0" ]; then
    echo "ERREUR : Ne pas exécuter ce conteneur en tant que root"
    echo "PostgreSQL doit être lancé par l'utilisateur postgres."
    exit 1
fi

# Variables par défaut si non fournies
: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_PASSWORD:=postgres}"
: "${POSTGRES_DB:=$POSTGRES_USER}"

export LANG=fr_FR.UTF-8
export LANGUAGE=fr_FR:fr
export LC_ALL=fr_FR.UTF-8

PGDATA="${PGDATA:-/var/lib/postgresql/data}"

# Chemin binaire PostgreSQL compilé
PG_CTL="/usr/local/pgsql/bin/pg_ctl"
INITDB="/usr/local/pgsql/bin/initdb"
PSQL="/usr/local/pgsql/bin/psql"
POSTGRES="/usr/local/pgsql/bin/postgres"

mkdir -p "$PGDATA"
mkdir -p /var/run/postgresql
chmod 700 "$PGDATA"

# ---------------------------------------- #
# Initialisation du cluster si nécessaire  #
# ---------------------------------------- #
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initialisation du cluster PostgreSQL…"

    $INITDB \
        --encoding UTF8 \
        --locale=fr_FR.UTF-8 \
        --data-checksums \
        -D "$PGDATA"

    echo "Configuration du superuser : $POSTGRES_USER"

    # Démarre PostgreSQL en mode local pour config initiale
    $PG_CTL -D "$PGDATA" -o "-c listen_addresses=''" -w start

    # Création user + DB
    $PSQL --command "ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';"

    if [ "$POSTGRES_USER" != "postgres" ]; then
        $PSQL --command "CREATE USER ${POSTGRES_USER} WITH SUPERUSER PASSWORD '${POSTGRES_PASSWORD}';"
    fi

    $PSQL --command "CREATE DATABASE ${POSTGRES_DB} OWNER ${POSTGRES_USER};"

    echo "Base ${POSTGRES_DB} créée"
    echo "User ${POSTGRES_USER} configuré"

    echo "Installation des extensions par défaut sur ${POSTGRES_DB}"

    $PSQL -d "$POSTGRES_DB" <<'EOF'
CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION IF NOT EXISTS hstore;
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS postgis_topology;
CREATE EXTENSION IF NOT EXISTS postgis_raster;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS address_standardizer;
CREATE EXTENSION IF NOT EXISTS ogr_fdw;
CREATE EXTENSION IF NOT EXISTS pgrouting;
CREATE EXTENSION IF NOT EXISTS pointcloud;
CREATE EXTENSION IF NOT EXISTS pointcloud_postgis;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
EOF

    echo "Extensions principales installées"

    # ------------------------------------------------------ #
    # Exécution des scripts dans docker-entrypoint-initdb.d  #
    # ------------------------------------------------------ #
    echo "Exécution des scripts d'initialisation…"
    for f in /docker-entrypoint-initdb.d/*; do
        case "$f" in
            *.sh)
                echo "Running $f (shell script)"
                . "$f"
                ;;
            *.sql)
                echo "Running $f (SQL script)"
                $PSQL -d "$POSTGRES_DB" -f "$f"
                ;;
            *.sql.gz)
                echo "Running $f (SQL.gz script)"
                gunzip -c "$f" | $PSQL -d "$POSTGRES_DB"
                ;;
            *)
                echo "Ignoré : $f"
                ;;
        esac
    done

    # Arrêt de PostgreSQL pour relancer en mode normal
    $PG_CTL -D "$PGDATA" -m fast -w stop

    echo "Cluster PostgreSQL initialisé avec succès"
fi

# ------------------------------ #
# Lancement final de PostgreSQL  #
# ------------------------------ #
echo "$(date) Lancement PostgreSQL…"

# arguments à zapper
if [ "$1" = "postgres" ]; then
    shift
fi
exec "$POSTGRES" -D "$PGDATA"