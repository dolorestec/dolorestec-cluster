FROM redis:8.0-alpine

LABEL maintainer="Dolorestec Team" \
      version="v8.0" \
      description="Redis custom image for Dolorestec"

# Configurações de segurança
RUN apk add --no-cache su-exec && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S redis && \
    adduser -u 1001 -S redis -G redis

# Configurações customizadas
COPY redis.conf /etc/redis/redis.conf

# Expor porta
EXPOSE 6379

# Usar usuário não-root
USER redis

# Comando padrão
CMD ["redis-server", "/etc/redis/redis.conf"]