-- Création de la base template mod_postgis 

        CREATE DATABASE mod_postgis
        WITH ENCODING='UTF8'
        LC_COLLATE='fr_FR.UTF-8'
        LC_CTYPE='fr_FR.UTF-8'
        TEMPLATE=template0
        OWNER=admin;

-- ATTENTION Se connecter à cette base en admin pour la préparer à devenir un template géocompatible.

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

-- Création du Rôle groupe "editeurs" sans connexion ni héritage, mais création db (à modifier si besoin).

CREATE ROLE editeurs CREATEDB CREATEROLE NOLOGIN NOINHERIT;


-- Définition des droits du groupe editeurs
GRANT ALL ON ALL TABLES TO editeurs;
GRANT ALL ON ALL SEQUENCES TO editeurs;
GRANT ALL ON ALL FUNCTIONS TO editeurs;
-- Définition des droits par défaut
ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO editeurs;
ALTER DEFAULT PRIVILEGES GRANT ALL ON SEQUENCES TO editeurs;
ALTER DEFAULT PRIVILEGES GRANT ALL ON FUNCTIONS TO editeurs;

-- Création du Rôle "editeur" avec connexion et héritage du groupe editeurs.
CREATE ROLE editeur LOGIN PASSWORD 'xyz1234!&?' INHERIT;
GRANT editeurs TO editeur;

-- Marquer la base comme template
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'mod_postgis';

-- Révoquer les droits publics de création sur le schéma public
REVOKE CREATE ON SCHEMA public FROM PUBLIC;