# Developer Documentation

## Environment Setup
1. **Prerequisites**:
   - Linux VM (Debian/Ubuntu recommended)
   - Docker Engine & Docker Compose (v2+)
   - `make`
   - `sudo` privileges for setup

2. **Configuration**:
   - Environment variables are in `srcs/.env`.
   - Secrets are in `secrets/*.txt`.
   - Host mapping in `/etc/hosts` is required for the domain `k123.42.fr`.

## Build & Launch
The project uses `Makefile` to simplify Docker commands.
- `make build`: Rebuilds images without starting.
- `make re`: Rebuilds and restarts containers.
- `make clean`: Stops containers and removes network.
- `make fclean`: Deep clean - removes containers, images, volumes, and networks.

## Architecture
- **Docker Compose**: `srcs/docker-compose.yml` is the source of truth.
- **Data Persistence**:
  - MariaDB data: `/home/k123/data/mariadb`
  - WordPress files: `/home/k123/data/wordpress`
  > *Note: These are bind mounts. Deleting these folders resets the application state.*

## Container Management
- **Logs**: `docker compose -f srcs/docker-compose.yml logs -f`
- **Shell Access**:
  ```bash
  docker exec -it wordpress sh
  docker exec -it mariadb sh
  docker exec -it nginx sh
  ```
