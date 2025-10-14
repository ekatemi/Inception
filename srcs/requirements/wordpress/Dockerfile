FROM debian:bookworm

RUN apt update && apt install -y php-fpm php-mysql wget tar

WORKDIR /var/www/html

# Установка WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

CMD ["php-fpm", "-F"]
