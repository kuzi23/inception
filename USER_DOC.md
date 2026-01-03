# User Documentation

## Overview
This stack provides a complete WordPress environment with a dedicated database and TLS-secured access.

## Starting the Project
To start the services:
```bash
make
```

To stop the services:
```bash
make down
```

## Accessing Services
- **Website**: Open [https://k123.42.fr](https://k123.42.fr) in your browser.
- **Admin Panel**: Go to [https://k123.42.fr/wp-admin](https://k123.42.fr/wp-admin).

## Credentials
Credentials are securely managed. For local testing, default values are:
- **WordPress Admin**: `admin` / (See `srcs/.env` or secrets)
- **Database User**: `wordpress` / `123456`

To manage credentials securely, edit the files in the `secrets/` directory:
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`

## Verification
You can check if services are running with:
```bash
docker ps
```
You should see 3 containers: `nginx`, `wordpress`, `mariadb`.
