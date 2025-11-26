#!/bin/bash
set -e

# Script de entrada para o GitHub Actions Runner
echo "🚀 Iniciando GitHub Actions Runner..."

# Verificar se RUNNER_TOKEN está definido
if [ -n "$RUNNER_TOKEN" ]; then
    echo "⚙️  Configurando runner..."
    cd /home/runner/actions-runner || true
    ./config.sh \
        --unattended \
        --url "${REPO_URL:-https://github.com/dolorestec/dolorestec-cluster}" \
        --pat "$RUNNER_TOKEN" \
        --name "${RUNNER_NAME:-dlrs-runner}" \
        --work "${RUNNER_WORKDIR:-_work}" \
        --replace
    echo "✅ Runner configurado!"
else
    echo "⚠️  RUNNER_TOKEN não definido — pulando configuração."
fi

# Executar o runner
echo "▶️  Iniciando runner..."
cd /home/runner/actions-runner || true
exec ./run.sh