FROM debian:bookworm

#switch off install questions
ENV DEBIAN_FRONTEND=noninteractive

RUN apt get update && apt get install -y nginx openssl
RUN mkdir -p /etc/ssl/private /etc/ssl/certs

# Генерация self-signed сертификатов, если их нет
RUN if [ ! -f /etc/ssl/certs/cert.pem ] || [ ! -f /etc/ssl/private/key.pem ]; then \
        openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/ssl/private/key.pem \
        -out /etc/ssl/certs/cert.pem \
        -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=wil/CN=wil.42.fr"; \
    fi

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/ssl/ /etc/ssl/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
