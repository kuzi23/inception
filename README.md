*This project has been created as part of the 42 curriculum by mkwizera.*

# Inception

## Description

Inception is a containerized infrastructure project built with Docker Compose inside a virtual machine. The mandatory stack contains:
- NGINX as the single public entrypoint on port 443 (HTTPS)
- WordPress running with PHP-FPM
- MariaDB as the database backend

Goal:
- Build each service from custom Dockerfiles (no ready-made service images)
- Connect services through an isolated Docker network
- Persist data with Docker named volumes
- Manage runtime configuration with environment variables and local secrets

## Instructions

1. Set host resolution (local machine):
```txt
127.0.0.1 mkwizera.42.fr
```

2. Create local secret files:
```sh
echo "strong_db_password" > secrets/db_password.txt
echo "strong_root_password" > secrets/db_root_password.txt
chmod 600 secrets/db_password.txt secrets/db_root_password.txt
```

3. Adjust non-secret variables in `srcs/.env`.

4. Build and start:
```sh
make
```

5. Stop:
```sh
make down
```

6. Clean everything:
```sh
make clean
```

## Technical Choices

### Virtual Machines vs Docker

- VM: full guest OS per instance, stronger isolation, heavier resource usage.
- Docker: shared host kernel, faster startup, smaller footprint, ideal for service-oriented local infrastructure.

This project uses Docker because the objective is reproducible service orchestration, not full OS virtualization.

### Secrets vs Environment Variables

- Environment variables are convenient for non-sensitive configuration (domain, usernames, titles).
- Secrets are safer for sensitive values (database passwords), because they are injected at runtime from files and should remain outside Git.

This project uses both:
- `srcs/.env` for non-sensitive runtime configuration
- `secrets/*.txt` for passwords

### Docker Network vs Host Network

- Docker bridge network isolates containers and provides service-to-service DNS.
- Host network bypasses this isolation and is explicitly forbidden by the project rules.

This stack uses a dedicated bridge network so services communicate internally by service name.

### Docker Volumes vs Bind Mounts

- Docker named volumes are managed by Docker and are portable within Compose workflows.
- Bind mounts directly map host paths and couple runtime behavior to host filesystem layout.

This stack persists WordPress and MariaDB data in named volumes.

## Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose specification: https://compose-spec.io/
- NGINX documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress + WP-CLI docs: https://wordpress.org/support/ and https://developer.wordpress.org/cli/commands/

## AI Usage

AI was used for:
- Compliance audit against the written subject requirements
- Refactoring startup scripts for secrets-based runtime initialization
- Drafting repository documentation (README, USER_DOC, DEV_DOC)

All generated suggestions were reviewed and adapted for this repository before applying.

