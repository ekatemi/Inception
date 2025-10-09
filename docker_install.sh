#!/bin/sh

# Прерываем при ошибке
set -e

# Проверка на root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Запустите этот скрипт от root или через sudo"
    exit 1
fi

echo "👉 Обновляем систему..."
apt-get update -y
apt-get upgrade -y

echo "👉 Устанавливаем зависимости..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo "👉 Добавляем GPG ключ Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "👉 Добавляем репозиторий Docker..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

echo "👉 Устанавливаем Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "✅ Docker установлен!"
docker --version

# Добавление пользователя в группу docker (чтобы не писать sudo docker)
if [ -n "$SUDO_USER" ]; then
    echo "👉 Добавляем пользователя $SUDO_USER в группу docker"
    usermod -aG docker "$SUDO_USER"
    echo "⚠️  Выйдите и зайдите снова, чтобы изменения вступили в силу"
fi
