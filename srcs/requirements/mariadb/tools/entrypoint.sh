#!/bin/bash
set -euo pipefail

MYSQL_DATADIR="/var/lib/mysql"

# Читаем пароли из Docker secrets
# (compose монтирует ../secrets -> /run/secrets)
ROOT_PWD_FILE="/run/secrets/db_root_password.txt"
DB_PWD_FILE="/run/secrets/db_password.txt"

# Переменные из .env (env_file подхватится docker-compose)
: "${MYSQL_DATABASE:?variable not set}"
: "${MYSQL_USER:?variable not set}"

ROOT_PWD=""
DB_PWD=""

if [ -f "$ROOT_PWD_FILE" ]; then
  ROOT_PWD="$(cat "$ROOT_PWD_FILE")"
fi
if [ -f "$DB_PWD_FILE" ]; then
  DB_PWD="$(cat "$DB_PWD_FILE")"
fi

# Устанавливаем права на datadir
mkdir -p "$MYSQL_DATADIR"
chown -R mysql:mysql "$MYSQL_DATADIR"
chmod 700 "$MYSQL_DATADIR"

# Инициализация базы (только при первом запуске)
if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
  echo "[MariaDB] Initializing database..."
  mariadb-install-db --user=mysql --datadir="$MYSQL_DATADIR" > /dev/null

  # Запускаем временно сервер в фоне
  mysqld_safe --datadir="$MYSQL_DATADIR" --skip-networking &

  # Ждём когда сервер станет доступен (не infinity loop)
  for i in $(seq 1 30); do
    if mysqladmin ping >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  # Выполняем начальную настройку: root pwd, база, пользователь
  # root может быть настроен без пароля через сокет, поэтому выполняем команды напрямую
  if [ -n "$ROOT_PWD" ]; then
    mysql -u root <<-SQL
      ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
      FLUSH PRIVILEGES;
SQL
  fi

  mysql -u root ${ROOT_PWD:+-p"${ROOT_PWD}"} <<-SQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PWD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  # Корректно останавливаем временный сервер
  mysqladmin -u root ${ROOT_PWD:+-p"${ROOT_PWD}"} shutdown || true

  echo "[MariaDB] Initialization finished."
fi

# Передаём исполнение основному процессу MariaDB (PID 1)
exec mysqld_safe --datadir="$MYSQL_DATADIR"
