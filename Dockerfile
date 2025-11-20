FROM debian:trixie
LABEL maintainer="Thomas Michel <thomas.michel@idgeo.fr>"

# Options variables personnalisables
# Note des versions : https://postgis.net/documentation/getting_started/install_windows/released_versions/

ENV POSTGRES_VERSION=17.7 \
    POSTGIS_VERSION=3.6.0 \
    PGROUTING_VERSION=4.0.0 \
    PGDATA=/var/lib/postgresql/data \
    LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8

#########################################
# Locale FR
#########################################

RUN apt-get update && apt-get install -y --no-install-recommends locales && \
    sed -i 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

#########################################
# Dépendances build
#########################################

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl gnupg lsb-release ca-certificates \
    build-essential libreadline-dev zlib1g-dev flex bison \
    autoconf automake libtool \
    libxml2-dev libxslt-dev libssl-dev libgeos-dev \
    libproj-dev libgdal-dev libjson-c-dev libprotobuf-c-dev \
    libpq-dev libgmp-dev cmake git pkg-config \
    libcurl4-openssl-dev libprotobuf-dev protobuf-c-compiler \
    sudo vim tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

#########################
## Compiler PostgreSQL ##
#########################

RUN wget https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.gz && \
    tar -xf postgresql-${POSTGRES_VERSION}.tar.gz && \
    cd postgresql-${POSTGRES_VERSION} && \
    ./configure --prefix=/usr/local/pgsql --with-openssl --with-libxml --with-libxslt && \
    make -j$(nproc) && make install && \
    cd contrib && \
    make && make install && \
    echo "=== Vérification hstore ===" && \
    ls -la hstore/ && \
    cd hstore && \
    make && \
    make install

ENV PATH="/usr/local/pgsql/bin:${PATH}"

#################################
# Création utilisateur postgres #
#################################

RUN groupadd -r postgres && \
    useradd -r -g postgres -d /var/lib/postgresql -s /bin/bash postgres && \
    mkdir -p "$PGDATA" && \
    chown -R postgres:postgres /var/lib/postgresql

######################
## Compiler PostGIS ##
######################

RUN wget https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz && \
    tar -xf postgis-${POSTGIS_VERSION}.tar.gz && \
    cd postgis-${POSTGIS_VERSION} && \
    ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config && \
    make -j$(nproc) && make install

########################
## Compiler pgRouting ##
########################

RUN git clone --branch v${PGROUTING_VERSION} https://github.com/pgRouting/pgrouting.git && \
    cd pgrouting && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local/pgsql .. && \
    make -j$(nproc) && make install

#########################
## Compiler Pointcloud ##
#########################

RUN git clone https://github.com/pgpointcloud/pointcloud.git && \
    cd pointcloud && \
    ./autogen.sh && \
    ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config && \
    make -j$(nproc) && make install

######################
## Compiler ogr_fdw ##
######################

RUN git clone https://github.com/pramsey/pgsql-ogr-fdw.git && \
    cd pgsql-ogr-fdw && \
    make -j$(nproc) && make install

#########################################
###       Nettoyage des sources       ### 
#########################################

RUN rm -rf /usr/src/*

#########################################
### Répertoires config + permissions  ###
#########################################

RUN mkdir -p /docker-entrypoint-initdb.d && \
    mkdir -p /var/run/postgresql && \
    chown -R postgres:postgres /var/run/postgresql

COPY docker-entrypoint.sh /usr/local/bin/
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 5432

USER postgres

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [""]