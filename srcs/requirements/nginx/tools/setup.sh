#!/bin/sh
set -e

if [ ! -f /etc/ssl/certs/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx.key \
        -out /etc/ssl/certs/nginx.crt \
        -subj "/C=FR/ST=Île-de-France/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

sed -i "s/DOMAIN_NAME/${DOMAIN_NAME}/g" /etc/nginx/http.d/default.conf

exec nginx -g "daemon off;"
