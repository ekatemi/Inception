FROM debian:bookworm

RUN apt update && apt install -y nginx openssl

# Создаём самоподписанный SSL-сертификат
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=ES/ST=Spain/L=Barcelona/O=42/CN=localhost"

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
