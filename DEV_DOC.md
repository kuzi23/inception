# DEV_DOC

## Prerequisites

- Linux VM environment
- Docker Engine installed
- Docker Compose v2 (`docker compose`)
- Local domain mapping for `mkwizera.42.fr`

## Initial Setup

1. Clone repository and enter project root.
2. Create local secret files:
```sh
echo "strong_db_password" > secrets/db_password.txt
echo "strong_root_password" > secrets/db_root_password.txt
chmod 600 secrets/db_password.txt secrets/db_root_password.txt
```
3. Update runtime variables in `srcs/.env`.

## Build And Launch

- Start stack:
```sh
make
```

- Rebuild stack:
```sh
make re
```

- Stop stack:
```sh
make down
```

- Full cleanup:
```sh
make clean
```

## Useful Docker Commands

- Compose config validation:
```sh
docker compose -f srcs/docker-compose.yml config
```

- List containers:
```sh
docker ps -a
```

- Inspect volumes:
```sh
docker volume ls
docker volume inspect wp db
```

- Follow logs:
```sh
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

## Data Persistence

- Database data is persisted in named volume `db`.
- WordPress files are persisted in named volume `wp`.
- Verify after restart by recreating containers and checking content is still present.

## Project Layout

- Compose: `srcs/docker-compose.yml`
- NGINX: `srcs/requirements/nginx`
- WordPress: `srcs/requirements/wordpress`
- MariaDB: `srcs/requirements/mariadb`
