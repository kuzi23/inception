# USER_DOC

This stack provides three services:
- NGINX (TLS termination on port 443)
- WordPress with PHP-FPM
- MariaDB database

## Start And Stop

1. Create local secrets:
```sh
echo "strong_db_password" > secrets/db_password.txt
echo "strong_root_password" > secrets/db_root_password.txt
chmod 600 secrets/db_password.txt secrets/db_root_password.txt
```

2. Review runtime variables:
```sh
cat srcs/.env
```

3. Build and start:
```sh
make
```

4. Stop containers:
```sh
make down
```

5. Remove full stack resources:
```sh
make clean
```

## Access

- Website: https://mkwizera.42.fr
- WordPress admin panel: https://mkwizera.42.fr/wp-admin

If DNS is not configured yet, map the domain to local host:
```txt
127.0.0.1 mkwizera.42.fr
```

## Credentials

- Non-secret config values are stored in `srcs/.env`.
- Database secret values are read from:
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`

## Health Checks

Check running containers:
```sh
docker ps
```

Check logs:
```sh
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Check HTTPS response:
```sh
curl -kI https://mkwizera.42.fr
```
