NAME = inception

all: $(NAME)

$(NAME):
	@mkdir -p /Users/electrolux/data/wordpress
	@mkdir -p /Users/electrolux/data/mariadb
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	@docker system prune -af
	@sudo rm -rf /Users/electrolux/data/wordpress/*
	@sudo rm -rf /Users/electrolux/data/mariadb/*

re: fclean all

.PHONY: all down clean fclean re
