FROM debian:bookworm

# Switch off interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    MARIADB_DATA_DIR=/var/lib/mysql

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose default MariaDB port
EXPOSE 3306

# Volume for DB persistence
VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["entrypoint.sh"]