FROM alpine:3.20

RUN apk update && apk add --no-cache python3

WORKDIR /app

COPY monitor.py .

CMD ["python3", "monitor.py"]
