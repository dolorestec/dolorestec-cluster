FROM redis:8.4.0-alpine

LABEL maintainer="Dolorestec Team" \
      version="v8.0" \
      description="Redis custom image for Dolorestec"

# Configurações customizadas
COPY redis.conf /etc/redis/redis.conf

# Expor porta
EXPOSE 6379

# Comando padrão com senha
CMD ["sh", "-c", "redis-server /etc/redis/redis.conf --requirepass $REDIS_PASSWORD"]