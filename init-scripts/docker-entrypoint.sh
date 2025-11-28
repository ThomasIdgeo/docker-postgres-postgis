#!/bin/bash
set -e

# Vérifier que nous ne sommes pas root
if [ "$(id -u)" = '0' ]; then
    echo "ERREUR: Ce script ne doit pas être exécuté en tant que root"
    echo "PostgreSQL refuse de démarrer avec l'utilisateur root pour des raisons de sécurité"
    exit 1
fi

# Fonction pour afficher les logs
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Variables d'environnement par défaut
POSTGRES_USER="${POSTGRES_USER:-admin}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$SUPERUSER_PASSWORD}"
PGDATA="${PGDATA:-/var/lib/postgresql/data}"

# Vérifier si PostgreSQL est déjà initialisé
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    log "Initialisation de PostgreSQL..."
    
    # Initialiser la base de données
    initdb -D "$PGDATA" --username="$POSTGRES_USER" --pwfile=<(echo "$POSTGRES_PASSWORD") --auth-local=trust --auth-host=md5
    
    log "Démarrage temporaire de PostgreSQL pour l'initialisation..."
    pg_ctl -D "$PGDATA" -o "-c listen_addresses=''" -w start
    
    # Créer la base de données par défaut si nécessaire
    if [ "$POSTGRES_DB" != "postgres" ]; then
        log "Création de la base de données: $POSTGRES_DB"
        createdb "$POSTGRES_DB"
    fi
    
    # Exécuter les scripts d'initialisation
    if [ -d /docker-entrypoint-initdb.d ]; then
        for f in /docker-entrypoint-initdb.d/*; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        log "Exécution de $f"
                        "$f"
                    else
                        log "Sourcing de $f"
                        . "$f"
                    fi
                    ;;
                *.sql)
                    log "Exécution de $f"
                    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" < "$f"
                    ;;
                *.sql.gz)
                    log "Exécution de $f"
                    gunzip -c "$f" | psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB"
                    ;;
                *)
                    log "Ignore $f"
                    ;;
            esac
        done
    fi
    
    # Créer les extensions PostGIS et pgRouting
    log "Création des extensions PostGIS et pgRouting..."
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS postgis;
        CREATE EXTENSION IF NOT EXISTS postgis_topology;
        CREATE EXTENSION IF NOT EXISTS pgrouting;
EOSQL
    
    log "Arrêt du serveur temporaire..."
    pg_ctl -D "$PGDATA" -m fast -w stop
    
    log "Initialisation terminée."
else
    log "PostgreSQL déjà initialisé."
fi

# Démarrer PostgreSQL en mode normal
if [ "$1" = 'postgres' ]; then
    log "Démarrage de PostgreSQL..."
    exec postgres -D "$PGDATA"
else
    # Exécuter la commande passée en paramètre
    exec "$@"
fi