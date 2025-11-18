FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# Create nginx user & group
RUN groupadd -r nginx && useradd -r -g nginx nginx

# SSL directory required for 42
RUN mkdir -p /etc/ssl/certs /etc/ssl/private

# SSL setup
RUN mkdir -p /etc/nginx/ssl /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 \
      -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=emikhayl.42.fr" \
      -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/emikhayl.42.fr.key \
      -out /etc/nginx/ssl/emikhayl.42.fr.crt

# Permissions (important if user nginx will be used)
RUN mkdir -p /var/cache/nginx /var/run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx /etc/nginx

COPY /conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]