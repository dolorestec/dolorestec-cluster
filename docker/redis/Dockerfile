FROM redis:8.0-alpine

LABEL maintainer="Dolorestec Team" \
      version="v8.0" \
      description="Redis custom image for Dolorestec"

# Configurações customizadas
COPY redis.conf /etc/redis/redis.conf

# Expor porta
EXPOSE 6379

# Comando padrão
CMD ["redis-server", "/etc/redis/redis.conf"]