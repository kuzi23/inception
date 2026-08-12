# Developer Documentation

## Introduction

This file is tailored for developers setting up, maintaining, or scaling the Inception infrastructure. It details configuration methods and basic troubleshooting concepts required when modifying the Docker Compose setup.

## Setup Environment from Scratch
1. **Prerequisites**: Make sure Docker, docker-compose, and make are available. Add `127.0.0.1 electrolux.42.fr` to the `/etc/hosts` file.
2. **Configuration Files**: Three containers require dedicated config directories inside `srcs/requirements`.
   - `mariadb`: Requires `conf/50-server.cnf` and an entrypoint script `tools/setup.sh`.
   - `wordpress`: Built on top of `php-fpm`. Uses `wp-cli` in `tools/setup.sh` to download and install.
   - `nginx`: Built using `openssl` in `tools/setup.sh` and maps to `conf/nginx.conf`.
3. **Secrets**: Crucial variables like database passwords must be stored inside files within the `secrets/` root folder. Make sure `.env` refers to them properly with the `run/secrets/` path in the container scope.

## Build and Launch
- Use `make` (alias for `docker compose -f srcs/docker-compose.yml up -d --build`).
- Inspect building details via `docker compose -f srcs/docker-compose.yml build --no-cache`.
- Check if containers are restarting constantly using `make logs` or `docker compose ... logs -f`.

## Data Storage
Docker persistency relies on volumes managed locally:
- `mariadb` maps `/var/lib/mysql` to the named volume `mariadb` which directs host to `/home/electrolux/data/mariadb`.
- `wordpress` maps `/var/www/html` to `/home/electrolux/data/wordpress`.

Always be mindful that modifying the files inside these mapped directories directly on the host alters the running state without checking `.gitignore`.
