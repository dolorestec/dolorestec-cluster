FROM postgres:18-alpine

LABEL maintainer="Dolorestec Team" \
      version="v18" \
      description="PostgreSQL custom image for Dolorestec"

# Configurações de segurança
RUN apk add --no-cache su-exec && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S postgres && \
    adduser -u 1001 -S postgres -G postgres

# Expor porta
EXPOSE 5432

# Usar usuário não-root
USER postgres

# Comando padrão
CMD ["postgres"]