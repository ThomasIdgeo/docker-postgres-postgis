#!/bin/bash
set -e

ENV_FILE="../.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Génération du fichier .env..."

  # Génération des identifiants
  SUPERUSER_PASSWORD=$(openssl rand -base64 12)
  DB_PASSWORD=$(openssl rand -base64 12)

  cat <<EOF > "$ENV_FILE"
# PostgreSQL Environment Variables
POSTGRES_USER=admin
POSTGRES_PASSWORD=$SUPERUSER_PASSWORD
POSTGRES_DB=mod_postgis
POSTGRES_PORT=x5432

# Locale Settings
POSTGRES_INITDB_ARGS=--encoding=UTF8 --locale=fr_FR.UTF-8
EOF

  echo "Fichier .env généré avec succès."
else
  echo "Le fichier .env existe déjà."
fi