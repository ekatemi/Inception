FROM debian:bookworm

# Avoid interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install Redis and tools
RUN apt-get update && \
    apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

# Allow connections from other containers
# (default is 127.0.0.1, which blocks access)
RUN sed -i 's/^bind .*/bind 0.0.0.0/' /etc/redis/redis.conf && \
    sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf && \
    sed -i 's/^# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/' /etc/redis/redis.conf && \
    sed -i 's/^supervised .*/supervised no/' /etc/redis/redis.conf && \
    sed -i 's/^daemonize yes/daemonize no/' /etc/redis/redis.conf

# Expose Redis default port (not required, but explicit)
EXPOSE 6379

# Run Redis in foreground mode
CMD ["redis-server", "/etc/redis/redis.conf"]
