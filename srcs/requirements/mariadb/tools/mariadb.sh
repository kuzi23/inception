#!/bin/sh

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB..."
	chown -R mysql:mysql /var/lib/mysql

	# init database
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
		return 1
	fi

	# Read secrets
	MYSQL_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
	MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;

DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED by '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF
	
	# run init sql
	/usr/bin/mysqld --user=mysql --bootstrap < $tfile
	rm -f $tfile
    echo "MariaDB initialized."
fi

# start server
exec /usr/bin/mysqld --user=mysql --console
