#!/bin/bash

set -e

# Read passwords securely from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

# Initialize database directory if not already
DATADIR="${MARIADB_DATA_DIR}"
if [ ! -d "${DATADIR}/${MYSQL_DATABASE}" ]; then
    echo "Initializing database..."
    
    mysqld_safe --skip-networking --user=mysql &
    pid="$!"

    # Wait until mysqld is ready
    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    # Create database and user
    cat << EOF | mysql -u root
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"
    echo "Database initialized successfully."
fi

# Run MariaDB in foreground
exec mysqld_safe --user=mysql \
    --bind-address=0.0.0.0 \
    #--character-set-server=utf8mb4 \
    #--collation-server=utf8mb4_general_ci
