#!/bin/sh

# Check if wp-config.php exists
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress: setting up..."
    
    # Wait for MariaDB
    echo "Waiting for MariaDB..."
    while ! nc -z $WORDPRESS_DB_HOST 3306; do
        sleep 1
    done
    echo "MariaDB is ready!"

    mkdir -p /var/www/html
    cd /var/www/html

    # Download WP-CLI
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # Download WordPress
    wp core download --allow-root

    # Read secrets
    WORDPRESS_DB_PASSWORD=$(cat $WORDPRESS_DB_PASSWORD_FILE)

    # Create config
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --allow-root

    # Install WordPress
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WORDPRESS_DB_USER \
        --admin_password=$WORDPRESS_DB_PASSWORD \
        --admin_email="admin@example.com" \
        --allow-root

    # Create second user
    wp user create \
        author \
        author@example.com \
        --role=author \
        --user_pass=123456 \
        --allow-root
        
    # Setup Redis
    wp config set WP_REDIS_HOST redis --allow-root
    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root

    echo "WordPress: set up!"
fi

exec /usr/sbin/php-fpm83 -F
