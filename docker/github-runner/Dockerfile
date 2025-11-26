FROM ubuntu:24.04

LABEL maintainer="Dolorestec Team" \
      version="2.330.0" \
      description="GitHub Actions Runner custom image for Dolorestec"

# Instalar dependências necessárias
RUN apt-get update && \
    apt-get install -y curl tar jq coreutils git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Criar usuário runner
RUN useradd -m -s /bin/bash runner && \
    mkdir -p /home/runner/actions-runner && \
    chown -R runner:runner /home/runner

# Mudar para usuário runner
USER runner
WORKDIR /home/runner/actions-runner

# Baixar e instalar o GitHub Actions Runner
RUN curl -o actions-runner-linux-x64-2.330.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.330.0/actions-runner-linux-x64-2.330.0.tar.gz && \
    echo "af5c33fa94f3cc33b8e97937939136a6b04197e6dadfcfb3b6e33ae1bf41e79a actions-runner-linux-x64-2.330.0.tar.gz" | sha256sum -c && \
    tar xzf ./actions-runner-linux-x64-2.330.0.tar.gz && \
    rm actions-runner-linux-x64-2.330.0.tar.gz

# Instalar dependências do .NET Core
USER root
RUN ./bin/installdependencies.sh && \
    rm -rf /var/lib/apt/lists/*
USER runner

# Criar script de entrada
USER root
RUN mkdir -p /opt/runner-scripts && \
    chown runner:runner /opt/runner-scripts

USER runner
COPY --chown=runner:runner entrypoint.sh /opt/runner-scripts/entrypoint.sh
RUN chmod +x /opt/runner-scripts/entrypoint.sh

# Comando padrão
ENTRYPOINT ["/opt/runner-scripts/entrypoint.sh"]