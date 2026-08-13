NAME = inception

all: $(NAME)

$(NAME):
	@mkdir -p /home/mkwizera/data/wordpress
	@mkdir -p /home/mkwizera/data/mariadb
	@docker compose -f srcs/docker-compose.yml up -d --build

down:
	@docker compose -f srcs/docker-compose.yml down

clean: down
	@docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	@docker system prune -af
	@sudo rm -rf /home/mkwizera/data/wordpress/*
	@sudo rm -rf /home/mkwizera/data/mariadb/*

re: fclean all

.PHONY: all down clean fclean re $(NAME)
