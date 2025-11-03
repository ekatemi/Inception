#!/bin/bash
set -e

cd /var/www/html

# Wait for MariaDB
sleep 5

# Generate wp-config.php
wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$(cat /run/secrets/db_password.txt)" \
    --dbhost="$MYSQL_HOST" \
    --allow-root

# Install WordPress (only first run)
if ! wp core is-installed --allow-root ; then
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="InceptionWP" \
        --admin_user="admin" \
        --admin_password="$(cat /run/secrets/db_root_password.txt)" \
        --admin_email="admin@example.com" \
        --allow-root
fi

exec php-fpm -F
