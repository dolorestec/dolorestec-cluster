FROM myoung34/github-runner:latest

LABEL maintainer="Dolorestec Team" \
      version="latest" \
      description="GitHub Runner custom image for Dolorestec"

# Instalar Docker CLI para builds
RUN apt-get update && \
    apt-get install -y docker.io curl && \
    rm -rf /var/lib/apt/lists/*

# Comando padrão
CMD ["/entrypoint.sh"]