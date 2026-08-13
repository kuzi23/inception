COMPOSE := $(shell if docker compose version >/dev/null 2>&1; then echo "docker compose"; elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; fi)

ifeq ($(strip $(COMPOSE)),)
$(error Neither 'docker compose' nor 'docker-compose' is available. Install Docker Compose and try again.)
endif

all:
	@$(COMPOSE) -f ./srcs/docker-compose.yml up

down:
	@$(COMPOSE) -f ./srcs/docker-compose.yml down

re:
	@$(COMPOSE) -f srcs/docker-compose.yml up --build

clean:
	@docker stop $$(docker ps -qa);\
	docker rm $$(docker ps -qa);\
	docker rmi -f $$(docker images -qa);\
	docker volume rm $$(docker volume ls -q);\
	docker network rm $$(docker network ls -q);\

.PHONY: all re down clean