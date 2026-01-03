name = inception

all:
	@mkdir -p /home/k123/data/wordpress
	@mkdir -p /home/k123/data/mariadb
	@docker-compose -f ./srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f ./srcs/docker-compose.yml down

re: down
	@docker-compose -f ./srcs/docker-compose.yml up -d --build

clean: down
	@docker system prune -a
	@sudo rm -rf /home/k123/data/wordpress/*
	@sudo rm -rf /home/k123/data/mariadb/*

fclean:
	@docker stop $$(docker ps -qa) 2>/dev/null || true
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo rm -rf /home/k123/data/wordpress/*
	@sudo rm -rf /home/k123/data/mariadb/*

.PHONY	: all build down re clean fclean