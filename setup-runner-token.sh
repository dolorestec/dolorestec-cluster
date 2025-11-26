#!/bin/bash

# Script simples para configurar GitHub Runner
# Uso: ./setup-runner-token.sh TOKEN

set -e

ENV_FILE=".env"
REPO_URL="https://github.com/dolorestec/dolorestec-cluster"

if [ -z "$1" ]; then
    echo "❌ Uso: ./setup-runner-token.sh TOKEN"
    echo "Obtenha o token em: $REPO_URL/settings/actions/runners/new"
    exit 1
fi

TOKEN="$1"

echo "🔧 Configurando GitHub Runner com token: $TOKEN"

# Atualizar .env
if grep -q "GITHUB_RUNNER_TOKEN" "$ENV_FILE"; then
    sed -i.bak "s/GITHUB_RUNNER_TOKEN=.*/GITHUB_RUNNER_TOKEN=$TOKEN/" "$ENV_FILE"
else
    echo "GITHUB_RUNNER_TOKEN=$TOKEN" >> "$ENV_FILE"
fi

echo "✅ .env atualizado!"

# Configurar runner diretamente
echo "⚙️  Configurando runner..."
docker exec dlrs-runner-00 ./config.sh \
    --unattended \
    --url "$REPO_URL" \
    --pat "$TOKEN" \
    --name "dlrs-runner-00" \
    --work "_work" \
    --replace

echo "✅ Runner configurado!"
echo "📊 Verifique logs: docker-compose logs github-runner-00"