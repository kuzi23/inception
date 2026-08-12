#!/bin/sh
set -e

WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

cd /var/www/html

if [ ! -f wp-config.php ]; then
    # Wait for database first
    while ! mysqladmin ping -h"mariadb" --silent; do
        sleep 1
    done

    wp core download --allow-root --force

    wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$(cat $MYSQL_USER_FILE) --dbhost=mariadb --allow-root

    wp core install --url=$WP_URL --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root

    wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD --role=author --allow-root
fi

exec php-fpm82 -F
