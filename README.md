*This project has been created as part of the 42 curriculum by electrolux.*

# Inception

## Description
This project aims to broaden knowledge of system administration by using Docker. We virtualize several Docker images, creating them in a personal virtual machine. It consists of setting up a small infrastructure composed of NGINX, WordPress, and MariaDB under specific rules.

## Instructions
1. Ensure Docker and Docker Compose are installed on your VM.
2. Update `/etc/hosts` to point `electrolux.42.fr` to `127.0.0.1`.
3. Create the required volume directories (the Makefile will attempt this for you):
   ```
   mkdir -p /home/electrolux/data/wordpress
   mkdir -p /home/electrolux/data/mariadb
   ```
4. Run `make` to build and launch the containers.
5. The site will be available at `https://electrolux.42.fr`.

## Resources
- Docker documentation: https://docs.docker.com/
- Nginx documentation: https://nginx.org/en/docs/

## Technical Choices

### Virtual Machines vs Docker
Virtual Machines abstract hardware, running a full guest OS, which makes them heavy but completely isolated. Docker containers abstract the application layer, sharing the host OS kernel. This makes containers lightweight and faster to start up.

### Secrets vs Environment Variables
Environment variables can be inspected by anyone with access to the container or docker inspect commands. Docker secrets provide a mechanism to securely transmit passwords which are mounted as read-only files in memory `/run/secrets/`, keeping them out of environment dumps.

### Docker Network vs Host Network
Using the host network maps all the container ports directly to the host interface without isolation. A custom Docker bridge network (`inception`) encapsulates communication between containers securely, only exposing specifically mapped ports (like 443) to the outside.

### Docker Volumes vs Bind Mounts
Bind mounts depend on the directory structure and OS of the host machine, tying the container to specific host paths. Docker volumes are managed entirely by Docker, providing better portability and performance across different environments. However, in this project, we explicitly use "named volumes" backed by a local driver to simulate persistent host data.
