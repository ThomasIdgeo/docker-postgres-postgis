-- Création de la base mod_postgis et Vérifier si la base existe déjà
/* DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_database WHERE datname = 'mod_postgis'
    ) THEN */
        CREATE DATABASE mod_postgis
        WITH ENCODING='UTF8'
        LC_COLLATE='fr_FR.UTF-8'
        LC_CTYPE='fr_FR.UTF-8'
        TEMPLATE=template0
        OWNER=postgres;
/*     END IF;
END $$; */
--Connection à la base pour la création des rôles
\c mod_postgis;

-- Extensions nécessaires
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
CREATE EXTENSION fuzzystrmatch;
CREATE EXTENSION pg_trgm;
CREATE EXTENSION hstore;
CREATE EXTENSION unaccent;
CREATE EXTENSION tablefunc;
CREATE EXTENSION postgis_tiger_geocoder;
CREATE EXTENSION pgrouting;

-- Création du Rôle groupe "editeurs" sans connexion ni héritage.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'editeurs'
    ) THEN
        CREATE ROLE editeurs NOLOGIN NOINHERIT;
    END IF;
END $$;

-- Définition des droits du groupe editeurs
GRANT USAGE, CREATE ON SCHEMA public TO editeurs;
GRANT ALL ON ALL TABLES IN SCHEMA public TO editeurs;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO editeurs;
-- Définition des droits par défaut
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO editeurs;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO editeurs;

-- Création du Rôle "editeur" avec connexion et héritage du groupe editeurs.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'editeur'
    ) THEN
        CREATE ROLE editeur LOGIN PASSWORD 'xyz1234!&?' INHERIT;
    END IF;
END $$;

-- Marquer la base comme template
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'mod_postgis';

-- Révoquer les droits publics de création sur le schéma public
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- Création du nouvel utilisateur superuser
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = 'idgeo'
    ) THEN
        CREATE ROLE idgeo WITH LOGIN PASSWORD 'xyz1234!&?' INHERIT;
    END IF;
END $$;