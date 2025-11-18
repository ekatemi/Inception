#!/bin/bash
set -e

# ──────────────────────────────────────────────
# 🧩 CONFIGURE PHP-FPM TO LISTEN ON PORT 9000
# ──────────────────────────────────────────────
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
CONF_FILE="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

if grep -q "listen = /run/php/php" "$CONF_FILE"; then
  echo "🔧 Updating PHP-FPM listen directive in $CONF_FILE"
  sed -i "s|listen = /run/php/php.*-fpm.sock|listen = 0.0.0.0:9000|" "$CONF_FILE"
else
  echo "✅ PHP-FPM already configured for TCP port 9000"
fi

# ──────────────────────────────────────────────
# 🔐 LOAD PASSWORDS FROM SECRETS
# ──────────────────────────────────────────────
if [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
  WORDPRESS_DB_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
fi

cd /var/www/html

# ──────────────────────────────────────────────
# 🕒 WAIT FOR MARIADB
# ──────────────────────────────────────────────
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"${WORDPRESS_DB_HOST%%:*}" --silent; do
  sleep 2
done
echo "✅ MariaDB is ready!"

# ──────────────────────────────────────────────
# ⚙️ CREATE CONFIG IF MISSING
# ──────────────────────────────────────────────
if [ ! -f wp-config.php ]; then
    echo "⚙️ Creating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root
fi

# ──────────────────────────────────────────────
# 🧱 INSTALL WORDPRESS IF NOT INSTALLED
# ──────────────────────────────────────────────
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "⚙️ Installing WordPress..."

    if [ ! -f wp-settings.php ]; then
        wp core download --allow-root
    fi

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

# ──────────────────────────────────────────────
# 👤 CREATE ADDITIONAL USER (IF SECRET PROVIDED)
# ──────────────────────────────────────────────
if [ -f "$CRED_FILE" ]; then
    echo "🔐 Found credentials secret, creating WordPress user..."
    USERNAME=$(sed -n '1p' "$CRED_FILE")
    USERPASS=$(sed -n '2p' "$CRED_FILE")
    USEREMAIL=$(sed -n '3p' "$CRED_FILE")

    echo "   → USERNAME: $USERNAME"
    echo "   → EMAIL: $USEREMAIL"
    echo "   → PASSWORD: [hidden, ${#USERPASS} chars]"

    if ! wp user get "$USERNAME" --field=ID --allow-root >/dev/null 2>&1; then
        wp user create "$USERNAME" "$USEREMAIL" \
            --user_pass="$USERPASS" \
            --role=author \
            --display_name="$USERNAME" \
            --allow-root
        echo "✅ Created user '$USERNAME' (${USEREMAIL})"
    else
        echo "ℹ️  User '$USERNAME' already exists, skipping."
    fi
else
    echo "⚠️ No credentials secret found, skipping user creation."
fi

# ──────────────────────────────────────────────
# 🚀 START PHP-FPM
# ──────────────────────────────────────────────
echo "🚀 Starting PHP-FPM..."
exec "$@"
