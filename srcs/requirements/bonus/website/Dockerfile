FROM alpine:3.20

RUN apk update && apk add --no-cache nodejs

WORKDIR /app

COPY server.js .
COPY public/ public/

EXPOSE 3000

CMD ["node", "server.js"]
