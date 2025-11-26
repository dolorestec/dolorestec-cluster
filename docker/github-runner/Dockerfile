# Use syntax for BuildKit features
# syntax=docker/dockerfile:1

############################################
# Builder: use Ubuntu to run installdependencies
############################################
FROM ubuntu:24.04 AS builder

LABEL maintainer="Dolorestec Team" \
      version="2.330.0" \
      description="GitHub Actions Runner builder for Dolorestec"

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tar jq coreutils git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash runner && mkdir -p /home/runner/actions-runner && chown -R runner:runner /home/runner

USER runner
WORKDIR /home/runner/actions-runner

# Baixar e extrair o runner (mantemos verificação de checksum como no Dockerfile original)
RUN curl -o actions-runner-linux-x64-2.330.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.330.0/actions-runner-linux-x64-2.330.0.tar.gz && \
    echo "af5c33fa94f3cc33b8e97937939136a6b04197e6dadfcfb3b6e33ae1bf41e79a actions-runner-linux-x64-2.330.0.tar.gz" | sha256sum -c && \
    tar xzf ./actions-runner-linux-x64-2.330.0.tar.gz && \
    rm actions-runner-linux-x64-2.330.0.tar.gz

# Voltar para root para executar script de dependências (o script é feito para Debian/Ubuntu)
USER root
RUN if [ -x ./bin/installdependencies.sh ]; then ./bin/installdependencies.sh; fi

############################################
# Final: imagem mínima baseada em Alpine + glibc compat
# Observação: actions-runner requer glibc; usamos uma base Alpine com glibc
############################################
FROM ubuntu:24.04 AS final

LABEL maintainer="Dolorestec Team" \
      version="2.330.0" \
      description="GitHub Actions Runner runtime (Ubuntu) for Dolorestec"

# instalar runtimes mínimos e utilitários, incluindo docker CLI (pacote `docker.io`)
# Nota: a documentação oficial recomenda configurar o repositório Docker antes de
# instalar `docker-ce*`. Para imagens do runner (onde montamos o socket do host),
# evitar instalar o daemon é preferível — aqui usamos `docker.io` do Ubuntu para
# fornecer o cliente CLI de forma simples e reprodutível.
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates bash curl jq git docker.io && \
    rm -rf /var/lib/apt/lists/*

# Instalar docker compose (CLI plugin) e buildx plugin (binários oficiais)
RUN mkdir -p /usr/local/lib/docker/cli-plugins /usr/libexec/docker/cli-plugins && \
    curl -fsSL -o /usr/local/lib/docker/cli-plugins/docker-compose "https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64" && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose && \
    curl -fsSL -o /usr/libexec/docker/cli-plugins/docker-buildx "https://github.com/docker/buildx/releases/download/v0.10.4/buildx-v0.10.4.linux-amd64" && \
    chmod +x /usr/libexec/docker/cli-plugins/docker-buildx || true

# Criar usuário runner e diretórios
RUN useradd -m -s /bin/bash runner && mkdir -p /home/runner/actions-runner /opt/runner-scripts && chown -R runner:runner /home/runner /opt/runner-scripts

WORKDIR /home/runner/actions-runner

# Copiar runner construído do stage builder
COPY --from=builder /home/runner/actions-runner /home/runner/actions-runner
# Allow build to specify where the entrypoint lives in the build context.
# Default assumes builds are invoked from the runner directory (compatible
# with `docker compose` executed inside `docker/github-runner`). CI can
# override this to `docker/github-runner/entrypoint.sh` when building from
# the repository root.
ARG ENTRYPOINT_SRC=entrypoint.sh
COPY --chown=runner:runner ${ENTRYPOINT_SRC} /opt/runner-scripts/entrypoint.sh
RUN chmod +x /opt/runner-scripts/entrypoint.sh && chown runner:runner /opt/runner-scripts/entrypoint.sh

# Instalar dependências do runner (ex: libicu para .NET 6) no estágio final
# Executa o script fornecido pelo próprio actions-runner que invoca apt-get
# para garantir que o runtime .NET não reclame durante o registro.
RUN if [ -x /home/runner/actions-runner/bin/installdependencies.sh ]; then \
            /home/runner/actions-runner/bin/installdependencies.sh; \
        fi
# Não incluir tokens ou secrets no build — entrypoint deve lidar com registre do token via variável/secret
USER runner

# Definir ponto de entrada (mantemos o comportamento atual)
ENTRYPOINT ["/opt/runner-scripts/entrypoint.sh"]