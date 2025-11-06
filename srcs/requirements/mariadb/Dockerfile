FROM debian:bookworm

# Switch off interactive prompts
#ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy config file
COPY tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose default MariaDB port
EXPOSE 3306

# Volume for DB persistence
VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["mysqld_safe"]
