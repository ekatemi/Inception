NAME = Inception
COMPOSE = docker compose -f ./srcs/docker-compose.yml

# ------------------ #
# Colors
RES	:=	\033[0m

R	:=	\033[0;31m
G	:=	\033[0;32m
Y	:=	\033[0;33m
B	:=	\033[0;34m
P	:=	\033[0;35m
C	:=	\033[0;36m
W	:=	\033[0;37m

all: build up
	@echo "Make help for a list of possible commands\n"

help:
	@echo "$(B)\n*** Possible commands:\n"
	@echo "\t config \t\t# Check sintax of docker-compose with .env variables"
	@echo "\t all \t\t# Build all the services"
	@echo "\t up \t\t# Start all services in detached (background) mode"
	@echo "\t up-debug \t# Start all services in foreground (debug mode)"
	@echo "\t down \t\t# Stop all services"
	@echo "\t restart \t# reload containers without rebuilding or tearing down networks/volumes."
	@echo "\t ps \t\t# List all containers (even stopped)"
	@echo "\t logs \t\t# Show logs of all services"
	@echo "\t clear \t\t# Clean everything and remove build cache"
	@echo "\t re \t\t# Clean and rebuild and restart all services"
	@echo "$(RES)"

build:
	@echo "$(B)--- Building Docker Images ---$(DEF)"
	$(COMPOSE) build
	@echo "$(G)✓ Builded OK$(DEF)"

check:
	@echo "$(B)--- Checking Dockerfiles ---$(DEF)"
	@docker build --check ./srcs/requirements/mariadb
	@docker build --check ./srcs/requirements/wordpress
	@docker build --check ./srcs/requirements/nginx
	@echo "$(G)✓ Dockerfiles OK$(DEF)"

up: setup-dirs
	@echo "$(G)Starting all services...$(RES)"
	$(COMPOSE) up -d

#only mariadb

mariadb-up: setup-dirs
	@echo "$(G)Starting MariaDB...$(RES)"
	$(COMPOSE) up mariadb -d

print-login:
	@echo "LOGIN is [$(LOGIN)]"


setup-dirs:
	mkdir -p /home/emikhayl/data/mariadb
	mkdir -p /home/emikhayl/data/wordpress

up-debug:
	@echo "$(Y)Starting all services in foreground (debug mode)...$(RES)"
	$(COMPOSE) up

down:
	@echo "$(R)Stopping all services...$(RES)"
	$(COMPOSE) down

restart:
	@echo "$(R)Restarting all services...$(RES)"
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f

ps:
	@echo "$(C)Listing containers...$(RES)"
	$(COMPOSE) ps -a

status:
	@echo "$(B)--- Volumes ---$(DEF)"
	@docker volume ls | grep srcs_ || echo "No volumes"
	@echo "$(B)--- Network ---$(DEF)"
	@docker network ls | grep srcs_ || echo "No network"
	@echo "--- Mounted paths in containers ---"
	@docker inspect mariadb wordpress | grep -E '"Source":| "Destination":' || true

#----Show docker compose with .env variables
config:
	$(COMPOSE) config

#---------------------------------------------------------------

fclean: clean
	@echo "$(Y)Removing Docker volumes for project $(COMPOSE_PROJECT_NAME)...$(RES)"
	docker compose -f ./srcs/docker-compose.yml down -v 


clean: down
	@echo "$(Y)Cleaning system (containers, networks, volumes, dangling images)...$(RES)"
	docker system prune -af --volumes
	@echo "$(Y)Clearing Docker builder cache...$(RES)"
	docker builder prune -af

re: fclean all

erase:
	@echo "$(Y)Removing data folders on host machine$(RES)"
	sudo rm -rf /home/emikhayl/data/mariadb
	sudo rm -rf /home/emikhayl/data/wordpress

check-empty:
	@echo "=== Checking project cleanup ==="

	@echo "\n--- 1. Checking local files and folders ---"
	@find . -type f \( -name "*.o" -o -name "*.tmp" -o -name "*.log" -o -name "*.pid" \)
	@echo "\n(If nothing is printed above, no build/temp files remain.)"

	@echo "\n--- 2. Checking Docker containers ---"
	@docker ps -a --filter "name=mariadb" --filter "name=wordpress" --filter "name=nginx"

	@echo "\n--- 3. Checking Docker images ---"
	@docker images | grep -E "mariadb|wordpress|nginx|srcs" || echo "No related images found"

	@echo "\n--- 4. Checking Docker volumes ---"
	@docker volume ls | grep -E "mariadb|wordpress|data|inception" || echo "No related volumes found"

	@echo "\n--- 5. Checking Docker networks ---"
	@docker network ls | grep inception || echo "No inception network found"
	
	@echo "\n--- 6. Checking folders on host ---"
	@test -d /home/emikhayl/data/wordpress && echo "wordpress folder still exists" || echo "No wordpress folder found"
	@test -d /home/emikhayl/data/mariadb && echo "mariadb folder still exists" || echo "No mariadb folder found"

	
	
	@echo "\n=== Cleanup check complete ==="


PHONY: all up up-debug down build clean clear re ps help restart