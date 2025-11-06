#!/bin/bash

set -e

# Read passwords securely from Docker secrets
MYSQL_ROOT_PASSWORD=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
MYSQL_PASSWORD=$(cat "$MYSQL_PASSWORD_FILE")

echo "Root password: $MYSQL_ROOT_PASSWORD"
echo "Ppassword: $MYSQL_PASSWORD"

# Initialize database directory if not already
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "Initializing database..."
    mysqld_safe --skip-networking &
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
exec mysqld_safe
