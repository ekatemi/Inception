NAME = inception
COMPOSE = ./srcs/docker-compose.yml

#all: up

up:
	docker compose -f $(COMPOSE) up -d --build

down:
	docker compose -f $(COMPOSE) down

clean: down
	docker system prune -af --volumes


re: clean all

