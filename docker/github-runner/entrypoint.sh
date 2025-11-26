#!/bin/bash
set -e

# Entrypoint: roda como root para preparar o ambiente, depois delega para runner.

echo "🚀 Iniciando GitHub Actions Runner (entrypoint rodando como root)..."


# Preparar script temporário executado como usuário `runner`.
RUNNER_SCRIPT=/home/runner/runner-start.sh
cat > "$RUNNER_SCRIPT" <<'EOS'
#!/bin/bash
set -e

echo "🚀 Iniciando GitHub Actions Runner (processo do runner)..."

# Verificar se GITHUB_TOKEN está definido
if [ -n "$GITHUB_TOKEN" ]; then
    REGISTRATION_TOKEN=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPOSITORY/actions/runners/registration-token)
    REGISTRATION_TOKEN=$(echo "$REGISTRATION_TOKEN" | jq -r .token)
    echo "Extracted token: $REGISTRATION_TOKEN"
    
    if [ "$REGISTRATION_TOKEN" = "null" ] || [ -z "$REGISTRATION_TOKEN" ]; then
        echo "❌ Falha ao obter token de registro. Verifique GITHUB_TOKEN e permissões."
        exit 1
    fi
    
    echo "⚙️  Configurando runner..."
    cd /home/runner/actions-runner || true
    # Verificar se já está configurado
    if [ -f .runner ]; then
        echo "Runner já configurado, removendo configuração antiga..."
        ./config.sh remove --token "$REGISTRATION_TOKEN" || ./config.sh remove || true
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