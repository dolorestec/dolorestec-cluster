#!/bin/bash
set -e

# Entrypoint: roda como root (imagem final não troca para USER runner) para poder
# ajustar permissões do socket do Docker do host e adicionar o usuário `runner`
# ao grupo correspondente. Depois delega a execução do runner para o usuário
# `runner` via runuser.

echo "🚀 Iniciando GitHub Actions Runner (entrypoint rodando como root)..."

# Se o socket do Docker estiver montado, detecte o GID do socket e crie um
# grupo com esse GID para que possamos adicionar o usuário runner a ele.
if [ -S /var/run/docker.sock ]; then
  DOCKER_GID=$(stat -c '%g' /var/run/docker.sock 2>/dev/null || true)
  if [ -n "$DOCKER_GID" ]; then
    echo "🔧 Encontrado docker.sock com GID=$DOCKER_GID, assegurando grupo no container..."
    if ! getent group docker >/dev/null 2>&1; then
      groupadd -g "$DOCKER_GID" docker || true
    fi
    # Adicionar usuário runner ao grupo (criado ou já existente)
    usermod -aG "$DOCKER_GID" runner 2>/dev/null || usermod -aG docker runner 2>/dev/null || true
  fi
fi

# Preparar script temporário executado como usuário `runner`.
RUNNER_SCRIPT=/tmp/runner-start.sh
cat > "$RUNNER_SCRIPT" <<'EOS'
#!/bin/bash
set -e

echo "🚀 Iniciando GitHub Actions Runner (processo do runner)..."

# Verificar se GITHUB_TOKEN está definido
if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔑 Obtendo token de registro do runner..."
    REGISTRATION_TOKEN=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPOSITORY/actions/runners/registration-token | jq -r .token)
    
    if [ "$REGISTRATION_TOKEN" = "null" ] || [ -z "$REGISTRATION_TOKEN" ]; then
        echo "❌ Falha ao obter token de registro. Verifique GITHUB_TOKEN e permissões."
        exit 1
    fi
    
    echo "⚙️  Configurando runner..."
    cd /home/runner/actions-runner || true
    # Se já existir uma configuração prévia, remova-a antes de reconfigurar.
    # Isso evita a mensagem: "Cannot configure the runner because it is already configured"
    if [ -x ./config.sh ]; then
        ./config.sh remove || true
    fi

    ./config.sh \
        --unattended \
        --url "${REPO_URL:-https://github.com/dolorestec/dolorestec-cluster}" \
        --token "$REGISTRATION_TOKEN" \
        --name "${RUNNER_NAME:-dlrs-runner}" \
        --work "${RUNNER_WORKDIR:-_work}" \
        --replace
    echo "✅ Runner configurado!"
else
    echo "⚠️  GITHUB_TOKEN não definido — pulando configuração."
fi

echo "▶️  Iniciando runner (exec ./run.sh)..."
cd /home/runner/actions-runner || true
exec ./run.sh
EOS

chmod +x "$RUNNER_SCRIPT"
chown runner:runner "$RUNNER_SCRIPT" || true

# Executar o script como usuário runner (herda variáveis de ambiente)
exec runuser -u runner -- "$RUNNER_SCRIPT"