#!/bin/sh

# Прерываем при ошибке
set -e

#!/bin/bash

set -e

echo "🔹 Updating packages..."
sudo apt-get update

echo "🔹 Installing prerequisites..."
sudo apt-get install -y ca-certificates curl gnupg

echo "🔹 Adding Docker GPG key..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "🔹 Adding Docker repository to Apt sources..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "🔹 Updating package list..."
sudo apt-get update

echo "🔹 Installing Docker Engine & plugins..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "🔹 Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "🔹 Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "✅ Docker installation complete!"
echo "➡️ Log out and log back in for group changes to take effect"
echo "➡️ Test with: docker run hello-world"

