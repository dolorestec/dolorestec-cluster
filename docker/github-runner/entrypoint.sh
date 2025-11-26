#!/bin/bash
set -e

# Script de entrada para o GitHub Actions Runner
echo "🚀 Iniciando GitHub Actions Runner..."

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

# Executar o runner
echo "▶️  Iniciando runner..."
cd /home/runner/actions-runner || true
exec ./run.sh