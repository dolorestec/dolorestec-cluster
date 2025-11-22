FROM rabbitmq:4.0-management-alpine

LABEL maintainer="Dolorestec Team" \
      version="v4.0" \
      description="RabbitMQ custom image for Dolorestec"

# Configurações customizadas
COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

# Expor portas
EXPOSE 5672 15672

# Comando padrão
CMD ["rabbitmq-server"]