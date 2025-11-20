# Composition Docker PostgreSQL / PostGIS / Pgrouting

## Description

Idgeo compatible.

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/Postgis_Logo_square.png?raw=true" width="150">

Mention des versions ***Current best***

[https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS](https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS)

Une image maison qui embarque PostgreSQL, PostGIS et Pgrouting 

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/postgresql-original.png?raw=true" width="150">

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/pgrouting_logo.png?raw=true" width="150">

Images from  [ThomasIdgeo\svg_ressources_idgeo](https://github.com/ThomasIdgeo/svg_ressources_idgeo/) 

## Usage

> [!IMPORTANT]
> Description d'une stack d'exemple.
> Suivre les étapes pour lancer la composition.

### 1- Cloner le repo 

Faire un git clone à l'endroit qui vous va bien (sur un serveur à priori).
  
### 2- Création de l'arborescence

Il faut créer une arborescence pour la composition.

Création du volume bindé pour avoir les fichiers de conf et data à ce même niveau. `pgdata/` et attribuer les permissions.

```bash
mkdir -p pgdata/ && \
sudo chown -R 999:999 pgdata/
```

Il faut maintenant créer le dossier initdb dans lequel il faudra enregistrer le docker-entrypoint.sh avec le `mv` et enfin le rendre exécutable `chmod +x`.

```bash
mkdir initdb && \
mv docker-entrypoint.sh initdb/  && \ 
sudo chmod +x initdb/docker-entrypoint.sh
```

### 3- Le docker-compose.yml

>[!WARNING]
> Il faut modifier le "achanger" pour le mot de passe de l'utilisateur du serveur et les options personnalisables.
> 


```yaml
services:
  db:
    image: thomasidgeo/idgeo-postgis:17.3.6
    container_name: postgis_idgeo # peut-être modifié
    restart: always
    environment:
      POSTGRES_USER: pguser # Personnalisable
      POSTGRES_PASSWORD: achanger # Personnalisable
      POSTGRES_DB: postgres
      PGDATA: /var/lib/postgresql/data/
    volumes:
      - ./pgdata:/var/lib/postgresql/data/
      - ./initdb:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432" # Personnalisable
    networks:
      - backend

networks:
  backend:

volumes:
  pgdata:
```

Voili Voilou

----------

Ce projet utilise les logiciels suivants :

- PostreSQL (PostgreSQL License)
- PostGIS (GPL v2)
- pgRouting (GPLv2)

Cette composition Docker est distribuée sous licence MIT.