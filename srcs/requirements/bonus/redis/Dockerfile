FROM alpine:3.20

RUN apk update && apk add --no-cache redis

# Disable protected mode to allow external connections (from wordpress container)
# and bind to all interfaces
RUN sed -i "s|bind 127.0.0.1|bind 0.0.0.0|g" /etc/redis.conf \
    && sed -i "s|protected-mode yes|protected-mode no|g" /etc/redis.conf \
    && echo "maxmemory 256mb" >> /etc/redis.conf \
    && echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis.conf"]
