FROM debian:11.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
	php-fpm php-mysqli php-cli curl ca-certificates mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

EXPOSE 9000

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d
COPY ./tools /var/www/

RUN chmod +x /var/www/wordpress_start.sh

ENTRYPOINT [ "/var/www/wordpress_start.sh" ]

CMD ["/usr/sbin/php-fpm7.4", "--nodaemonize"]