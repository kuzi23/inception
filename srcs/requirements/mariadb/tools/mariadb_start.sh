#!/bin/sh
set -eu

read_secret() {
    var_name="$1"
    file_var_name="${var_name}_FILE"
    eval "file_path=\${$file_var_name:-}"

    if [ -n "$file_path" ] && [ -f "$file_path" ]; then
        value="$(cat "$file_path")"
        export "$var_name=$value"
    fi
}

read_secret MYSQL_PASSWORD
read_secret MYSQL_ROOT_PASSWORD

# MYSQL_HOST is meant for the wordpress client, not for this container's own socket connections
unset MYSQL_HOST

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

attempt=0
until mysqladmin --protocol=socket -h localhost ping >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 30 ]; then
        echo "MariaDB: startup timeout" >&2
        kill "$pid"
        exit 1
    fi
    sleep 1
done

if [ ! -f /var/lib/mysql/.inception_init ]; then
    mysql --protocol=socket -h localhost -uroot <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
    touch /var/lib/mysql/.inception_init
    chown mysql:mysql /var/lib/mysql/.inception_init
fi

mysqladmin --protocol=socket -h localhost -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

exec "$@" --user=mysql --datadir=/var/lib/mysql
