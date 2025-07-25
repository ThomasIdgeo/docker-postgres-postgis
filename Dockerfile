FROM debian:bookworm-slim
LABEL maintainer="Thomas Michel <thomas.michel@idgeo.fr>"

# Options variables personnalisables
ENV POSTGRES_VERSION=16.9 \
    POSTGIS_VERSION=3.5.3 \
    PGROUTING_VERSION=3.6.0 \
    PGUSER=pguser \
    POSTGRES_DB=postgres \
    POSTGRES_PASSWORD=achanger \
    PGDATA=/var/lib/postgresql/data

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget curl gnupg lsb-release ca-certificates \
    build-essential libreadline-dev zlib1g-dev flex bison \
    libxml2-dev libxslt-dev libssl-dev libgeos-dev \
    libproj-dev libgdal-dev libjson-c-dev libprotobuf-c-dev \
    libpq-dev libgmp-dev cmake git pkg-config \
    protobuf-c-compiler \
    sudo vim tini && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -r $PGUSER && useradd -r -g $PGUSER $PGUSER && \
    mkdir -p $PGDATA && chown -R $PGUSER:$PGUSER /var/lib/postgresql

# Compiler PostgreSQL
WORKDIR /usr/src
RUN wget https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.gz && \
    tar -xf postgresql-${POSTGRES_VERSION}.tar.gz && \
    cd postgresql-${POSTGRES_VERSION} && \
    ./configure --prefix=/usr/local/pgsql --with-openssl && \
    make -j$(nproc) && make install && \
    cd contrib && \
    make && make install && \
    echo "=== Vérification hstore ===" && \
    ls -la hstore/ && \
    cd hstore && \
    make && \
    make install

ENV PATH="/usr/local/pgsql/bin:${PATH}"

# Compiler PostGIS
RUN wget https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz && \
    tar -xf postgis-${POSTGIS_VERSION}.tar.gz && \
    cd postgis-${POSTGIS_VERSION} && \
    ./configure --with-pgconfig=/usr/local/pgsql/bin/pg_config && \
    make -j$(nproc) && make install

# Compiler pgRouting
RUN git clone --branch v${PGROUTING_VERSION} https://github.com/pgRouting/pgrouting.git && \
    cd pgrouting && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local/pgsql .. && \
    make -j$(nproc) && make install

# Création des répertoires avec les bonnes permissions
RUN mkdir -p /docker-entrypoint-initdb.d && \ 
    mkdir -p /var/run/postgresql && \    
    chown -R $PGUSER:$PGUSER /docker-entrypoint-initdb.d && \
    chown -R $PGUSER:$PGUSER /var/run/postgresql && \
    chown -R $PGUSER:$PGUSER $PGDATA

# Copie des scripts
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown $PGUSER:$PGUSER /usr/local/bin/docker-entrypoint.sh

# Nettoyer les sources pour réduire la taille de l'image
WORKDIR /
RUN rm -rf /usr/src/*

EXPOSE 5432

# Changer vers l'utilisateur pguser AVANT l'entrypoint
USER $PGUSER

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres"]
