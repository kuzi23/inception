# User Documentation

## Introduction

This document provides instructions for an end user or administrator to start, stop, and access the services provided by the Inception infrastructure.

## Services Provided
- **Nginx**: A web server securely handling SSL/TLS limits in front of the application.
- **WordPress**: A fully functional content management system available via a local domain name.
- **MariaDB**: The backend database engine persistently storing all website data securely via Docker secrets.

## Managing the Infrastructure

### Start the Project
Navigate to the root directory `inception` and execute:
```bash
make
```
This automatically manages directory initialization and starts all required Docker containers properly.

### Stop the Project
To bring down the project gracefully:
```bash
make down
```
To fully remove containers and volumes:
```bash
make clean
```
To fully remove images and clean the system:
```bash
make fclean
```

## Accessing the Website
- **Website**: Open a browser and navigate to `https://mkwizera.42.fr` (accept the self-signed certificate exception).
- **Admin Panel**: Navigate to `https://mkwizera.42.fr/wp-admin`. The login credentials correspond to `WP_ADMIN_USER` and `WP_ADMIN_PASSWORD_FILE` stored safely in the `.env` file and secrets directory.

## Checking the Services
You can verify the services are running correctly by checking docker containers:
```bash
docker compose -f srcs/docker-compose.yml ps
```
Or check the logs of a specific service:
```bash
docker compose -f srcs/docker-compose.yml logs nginx
```
