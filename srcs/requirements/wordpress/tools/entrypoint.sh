#!/bin/bash
set -e

# --- Configure PHP-FPM to listen on 0.0.0.0:9000 instead of socket ---

PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
CONF_FILE="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

if grep -q "listen = /run/php/php" "$CONF_FILE"; then
  echo "🔧 Updating PHP-FPM listen directive in $CONF_FILE"
  sed -i "s|listen = /run/php/php.*-fpm.sock|listen = 0.0.0.0:9000|" "$CONF_FILE"
else
  echo "✅ PHP-FPM already configured for TCP port 9000"
fi

if [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
  WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
fi

cd /var/www/html

echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST%%:*}" --silent; do
  sleep 2
done
echo "✅ MariaDB is ready!"

# Если wp-config.php ещё нет, создаём
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "⚙️  Installing WordPress..."

    # Скачиваем WP (если ещё не скачан)
    if [ ! -f wp-settings.php ]; then
        wp core download --allow-root
    fi

    # Создаём wp-config.php
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root

    # Устанавливаем WordPress
    wp core install \
        --url="${WORDPRESS_URL}" \
        --title="${WORDPRESS_TITLE}" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
else
    echo "✅ WordPress already installed."
fi


echo "🚀 Starting PHP-FPM..."
exec "$@"