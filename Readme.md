# Composition Docker PostgreSQL / PostGIS / Pgrouting

## Description

> [!IMPORTANT]
> La branche principale s'envisage pour une utilisation en dev.
> Les branches supplémentaires permettent la construction des images docker.

Idgeo compatible.

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/Postgis_Logo_square.png?raw=true" width="80">

Mention des versions ***Current best***
[https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS](https://trac.osgeo.org/postgis/wiki/UsersWikiPostgreSQLPostGIS)

Une image maison qui embarque PostgreSQL, PostGIS et Pgrouting 

<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/postgresql-original.png?raw=true" width="75">
<img src="https://github.com/ThomasIdgeo/svg_ressources_idgeo/blob/main/icons_png/pgrouting_logo.png?raw=true" width="75">

Images from  [ThomasIdgeo\svg_ressources_idgeo](https://github.com/ThomasIdgeo/svg_ressources_idgeo/)

## Usages

> [!IMPORTANT]
> Description d'une stack d'exemple.
> Suivre les étapes pour lancer la composition.

### 1- Cloner le repo 

Faire un git clone à l'endroit qui vous va bien (sur un serveur à priori).
  
### 2- Création de l'arborescence

Il faut créer une arborescence pour la composition.

- Création du volume bindé pour avoir les fichiers de conf et data à ce même niveau. `pgdata/` et attribuer les permissions.

```bash
sudo mkdir pgdata \ &&
sudo chown -R 999:999 pgdata
```

- On rend le fichier init-env.sh et docker-entrypoint.sh exécutable `chmod +x`.

```bash
sudo chmod +x init-scripts/init-env.sh && \
sudo chmod +x init-scripts/docker-entrypoint.sh
```

### 3- Derniers préparatifs -  Etape par étape

1. Le script suivant va générer un fichier .env et généré de manière aléatoire un mot de passe pour un super-utilisateur du serveur. Il s'agit de personnaliser le fichier intit-scripts/init-env.sh et de changer le port évantuellement.
2. Se positionner dans le dossier init-scripts ``cd init-scripts`` 
3. Exécuter le fichier intit-scripts/init-env.sh ``sudo ./init-env.sh``. Le fichier .env est généré dans le dossier parent.
4. Lancer la composition (cf ci-dessous)
5. Tester la connexion à la base avec les éléments trouvables dans le .env (en ayant modifier pg_hba et postgres.conf listen_adress)
6. [*optionnel*] Création du template postgis avec le script sql init-scripts/01-init-template-postgis.sql (après une première connexion en superutilisateur)

### 4- Le docker-compose.yml => Lancer la composition

>[!WARNING]
> L'étape précédente permet de générer les variables d'environnment
> 

```yaml
sudo docker compose up --build -d
```
- On vérifie si le container apparait dans les processus docker

```bash
sudo docker compose ps
```
- On vérifie les logs

```bash
sudo docker compose logs -f -n 100
```
:white_check_mark: On doit voir : "[1] LOG:  database system is ready to accept connections"
Et on peut se connecter avec son client préféré !

### 5- Les conf du serveur

>[!IMPORTANT]
> Il est recommandé de variabiliser certains éléments ...

>[!WARNING]
> Il est aussi recommandé d'ajuster les fichiers de configurations postgresql.conf (listenadress notament et pgtune en fonction de la machine qui héberge) et pg_hab.conf (en fonction de votre réseau).

N'oublions pas de configurer notre base template et des rôles adaptés à nos besoins. Vous trouverez une série de commande pour créer une base template géo-compatible et un rôle "editeurs" jouant qui permet de gérer un profil convenable. Attention à suivre les indications des commentaires.

Voili Voilou

----------

Ce projet utilise les logiciels suivants :

- PostreSQL (PostgreSQL License)
- PostGIS (GPL v2)
- pgRouting (GPLv2)

Cette composition Docker est distribuée sous licence MIT.