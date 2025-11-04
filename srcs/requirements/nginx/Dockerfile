FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    nginx openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create nginx user & group
RUN groupadd -r nginx && useradd -r -g nginx nginx

# SSL directory required for 42
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# Generate SSL certificate if not exist
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/inception.key \
    -out /etc/ssl/certs/inception.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Cadet/CN=${DOMAIN_NAME}"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

