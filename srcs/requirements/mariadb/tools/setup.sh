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
    mysqld --user=mysql --bootstrap < /tmp/init.sql
fi

rm -f /tmp/init.sql

exec mysqld_safe --user=mysql
