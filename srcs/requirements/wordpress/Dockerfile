FROM alpine:3.20

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-mbstring \
    php83-openssl \
    php83-xml \
    php83-zip \
    php83-phar \
    curl

# Adjust PHP configuration
RUN ln -s /usr/bin/php83 /usr/bin/php

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/make_wordpress.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/make_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/make_wordpress.sh"]
