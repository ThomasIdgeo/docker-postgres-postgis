FROM thomasidgeo/idgeo-postgis:17.3.6

# Installer les locales et générer fr_FR.UTF-8
USER root
RUN apt-get update && \
    apt-get install -y locales && \
    sed -i '/fr_FR.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8

# Définir la locale par défaut
ENV LANG=fr_FR.UTF-8
ENV LANGUAGE=fr_FR.UTF-8
ENV LC_ALL=fr_FR.UTF-8

# Créer l'utilisateur postgres s'il n'existe pas et configurer les permissions
RUN if ! id postgres > /dev/null 2>&1; then \
        useradd -r -s /bin/bash -d /var/lib/postgresql postgres; \
    fi && \
    mkdir -p /var/lib/postgresql/data && \
	chmod 700 /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

# Copier les scripts d'initialisation
COPY init-scripts/ /docker-entrypoint-initdb.d/

# Rendre les scripts exécutables et ajuster les permissions
RUN chmod +x /docker-entrypoint-initdb.d/*.sh && \
    chown -R postgres:postgres /docker-entrypoint-initdb.d/

# Copier le script d'entrée
COPY init-scripts/docker-entrypoint.sh /usr/local/bin/
RUN # Régler pb win vs linux
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown postgres:postgres /usr/local/bin/docker-entrypoint.sh

# Passer à l'utilisateur postgres avant d'exécuter le script
USER postgres

# Définir le répertoire de travail
WORKDIR /var/lib/postgresql

# Utiliser le script d'entrée personnalisé
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["postgres"]