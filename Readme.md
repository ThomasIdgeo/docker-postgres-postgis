# Image Docker PostgreSQL / PostGIS / Pgrouting

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

1- faire un git clone à l'endroit qui vous va bien (sur un serveur à priori).
  
2- Il faut créer une arborescence pour la composition.

Création du volume bindé pour avoir les fichier de conf et data à ce même niveau. `pgdata/` et attribuer les permissions.

```bash
mkdir -p pgdata/ && \
sudo chown 999:999 pgdata/
```

Il faut maintenant créer le dossier initdb dans lequel il faudra enregistrer le docker-entrypoint.sh + d'autre fichier de conf si vous désriez.

```bash
mkdir initdb && \
mv docker-entrypoint.sh initdb/
```

>[!WARNING]
> Il faut modifier le "achanger" pour le mot de passe de l'utilisateur du serveur.
> 
3- Le docker-compose.yml

```yaml
services:
  db:
    image: thomasidgeo/idgeo-postgis:16.3.3

    container_name: postgis_idgeo
    restart: always
    environment:
      POSTGRES_USER: pguser
      POSTGRES_PASSWORD: achanger
      POSTGRES_DB: postgres
      PGDATA: /var/lib/postgresql/data/
    volumes:
      - ./pgdata:/var/lib/postgresql/data/
      - ./initdb:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    networks:
      - backend

networks:
  backend:

volumes:
  pgdata:
```

