FROM alpine:3.19

RUN apk update && apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-phar \
    php82-mbstring \
    php82-openssl \
    curl \
    mariadb-client \
    wget \
    tar

RUN addgroup -S www-data 2>/dev/null || true \
    && adduser -S -D -H -G www-data www-data 2>/dev/null || true

RUN mkdir -p /run/php \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html /run/php

COPY conf/www.conf /etc/php82/php-fpm.d/www.conf

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && ln -sf /usr/bin/php82 /usr/bin/php

COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
