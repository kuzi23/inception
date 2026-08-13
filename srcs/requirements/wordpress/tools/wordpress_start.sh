#!/bin/sh
set -eu

if [ -n "${MYSQL_PASSWORD_FILE:-}" ] && [ -f "${MYSQL_PASSWORD_FILE}" ]; then
	export MYSQL_PASSWORD="$(cat "${MYSQL_PASSWORD_FILE}")"
fi

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD is required}"
: "${MYSQL_HOST:=mariadb}"

sed -i "s|listen = /run/php/php7.4-fpm.sock|listen = 9000|" "/etc/php/7.4/fpm/pool.d/www.conf"
mkdir -p /run/php/
touch /run/php/php7.4-fpm.pid

chown -R www-data:www-data /var/www
chmod -R 755 /var/www

if [ ! -f /usr/local/bin/wp ]; then
	curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
fi

attempt=0
until mysqladmin --protocol=tcp -h "${MYSQL_HOST}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" ping >/dev/null 2>&1; do
	attempt=$((attempt + 1))
	if [ "$attempt" -ge 30 ]; then
		echo "WordPress: database unreachable, giving up" >&2
		exit 1
	fi
	sleep 1
done

if [ ! -f /var/www/html/.inception_init ]; then
	echo "WordPress: setting up..."
	mkdir -p /var/www/html
	cd /var/www/html
	if [ ! -f wp-config.php ]; then
		wp core download --allow-root
		cp /var/www/wp-config.php /var/www/html/wp-config.php
	fi
	wp core install --allow-root --url="${WP_URL}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN_LOGIN}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}"
	wp user create --allow-root "${WP_USER_LOGIN}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}"
	touch /var/www/html/.inception_init
	chown www-data:www-data /var/www/html/.inception_init
	echo "WordPress: setup complete"
fi

exec "$@"