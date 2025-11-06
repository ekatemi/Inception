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
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
      -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=emikhayl.42.fr" \
      -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/emikhayl.42.fr.key \
      -out /etc/nginx/ssl/emikhayl.42.fr.crt

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

