FROM alpine:3.19

RUN apk update && apk add --no-cache nginx openssl \
    && mkdir -p /etc/nginx/http.d

ARG DOMAIN_NAME
ENV DOMAIN_NAME=${DOMAIN_NAME}

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup.sh"]
