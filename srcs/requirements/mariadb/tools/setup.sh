#!/bin/sh
set -e

DB_PASSWORD=$(cat ${MYSQL_USER_FILE})
DB_ROOT_PASSWORD=$(cat ${MYSQL_ROOT_PASSWORD_FILE})

cat << EOF > /tmp/init.sql
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # bootstrap mode does not reliably persist CREATE USER/GRANT, so init via a real socket-only instance instead
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    tmp_pid=$!

    for i in $(seq 1 30); do
        mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1 && break
        sleep 1
    done

    mysql --socket=/run/mysqld/mysqld.sock < /tmp/init.sql

    mysqladmin --socket=/run/mysqld/mysqld.sock shutdown
    wait "$tmp_pid" 2>/dev/null || true
fi

rm -f /tmp/init.sql

exec mariadbd --user=mysql
