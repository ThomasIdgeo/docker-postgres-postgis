# Composition Docker PostgreSQL / PostGIS / Pgrouting

## Description

> [!IMPORTANT]
> La branche principale s'envisage pour une utilisation en dev.
> Les branches supplémentaires permettent la construction des images docker.

Idgeo compatible.

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/Postgis_Logo_square.png?raw=true" width="150">

Mention des versions ***Current best***

[https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS](https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS)

Une image maison qui embarque PostgreSQL, PostGIS et Pgrouting 

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/postgresql-original.png?raw=true" width="150">

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/pgrouting_logo.png?raw=true" width="150">

Images from  [ThomasIdgeo\svg_ressources_idgeo](https://github.com/ThomasIdgeo/svg_ressources_idgeo/) 

## Usages

> [!IMPORTANT]
> Description d'une stack d'exemple.
> Suivre les étapes pour lancer la composition.

### 1- Cloner le repo 

Faire un git clone à l'endroit qui vous va bien (sur un serveur à priori).
  
### 2- Création de l'arborescence

Il faut créer une arborescence pour la composition.

Création du volume bindé pour avoir les fichiers de conf et data à ce même niveau. `pgdata/` et attribuer les permissions.

```bash
sudo chown -R 999:999 pgdata
```

On rend le fichier init-env.sh et docker-entrypoint.sh exécutable `chmod +x`.

```bash
sudo chmod +x init-scripts/init-env.sh && \
sudo chmod +x init-scripts/docker-entrypoint.sh
```

### 3- Derniers préparatifs

1. Personnaliser le fichier intit-scripts/init-env.sh
2. Exécuter le fichier intit-scripts/init-env.sh (en étant positionné dans le dosiier /init-scripts) sudo ./init-env.sh
3. Lancer la composition (cf ci-dessous)
4. Tester la connexion à la base avec les éléments trouvables dans le .env
5. Création du template postgis avec le script sql init-scripts/01-init-template-postgis.sql (après une première connexion en superutilisateur)

### 4- Le docker-compose.yml => Lancer la composition

>[!WARNING]
> L'étape précédente permet de générer les variables d'environnment
> 

```yaml
sudo docker compose up --build -d
```

### 5- Les conf du serveur

>[!IMPORTANT]
> Il est indispensable de variabiliser certains éléments ...

>[!WARNING]
> Il est recommandé aussi d'ajuster les fichiers de configurations postgresql.conf (listenadress notament) et pg_hab.conf 

N'oublions pas de configurer notre base template et des rôles adaptés à nos besoins.

Voili Voilou

----------

Ce projet utilise les logiciels suivants :

- PostreSQL (PostgreSQL License)
- PostGIS (GPL v2)
- pgRouting (GPLv2)

Cette composition Docker est distribuée sous licence MIT.