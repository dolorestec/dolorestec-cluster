#!/bin/bash

# Script para configurar GitHub Runner Token
# Uso: ./setup-runner-token.sh [TOKEN] ou ./setup-runner-token.sh --generate [PAT_TOKEN]

set -e

ENV_FILE=".env"
REPO_URL="https://github.com/dolorestec/dolorestec-cluster"

echo "🔧 Configuração do GitHub Runner Token"
echo "======================================"

# Função para gerar token usando PAT
generate_token() {
    local pat_token="$1"
    echo "🔄 Gerando registration token usando Personal Access Token..."

    response=$(curl -s -H "Authorization: token $pat_token" \
                   -H "Accept: application/vnd.github.v3+json" \
                   -X POST \
                   "$REPO_URL/actions/runners/registration-token")

    if echo "$response" | grep -q '"token"'; then
        token=$(echo "$response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        echo "$token"
    else
        echo "❌ Erro ao gerar token. Verifique se o PAT tem permissões para gerenciar runners."
        echo "Resposta da API: $response"
        exit 1
    fi
}

if [ "$1" = "--generate" ]; then
    if [ -z "$2" ]; then
        echo "❌ Uso: ./setup-runner-token.sh --generate SEU_PAT_TOKEN"
        echo ""
        echo "Para criar um PAT:"
        echo "1. Vá para: https://github.com/settings/tokens"
        echo "2. Clique em 'Generate new token (classic)'"
        echo "3. Selecione scope: repo, workflow"
        echo "4. Copie o token gerado"
        exit 1
    fi

    NEW_TOKEN=$(generate_token "$2")
elif [ -z "$1" ]; then
    echo ""
    echo "Para gerar um novo registration token:"
    echo "1. Vá para: $REPO_URL/settings/actions/runners"
    echo "2. Clique em 'New self-hosted runner'"
    echo "3. Copie o 'Registration Token'"
    echo "4. Execute: ./setup-runner-token.sh SEU_TOKEN_AQUI"
    echo ""
    echo "Ou use um Personal Access Token:"
    echo "./setup-runner-token.sh --generate SEU_PAT_TOKEN"
    echo ""
    echo "Token atual no .env:"
    grep "GITHUB_RUNNER_TOKEN" "$ENV_FILE" || echo "Token não encontrado"
    exit 1
else
    NEW_TOKEN="$1"
fi

echo "📝 Atualizando token no arquivo .env..."
if grep -q "GITHUB_RUNNER_TOKEN" "$ENV_FILE"; then
    # Atualizar token existente
    sed -i.bak "s/GITHUB_RUNNER_TOKEN=.*/GITHUB_RUNNER_TOKEN=$NEW_TOKEN/" "$ENV_FILE"
else
    # Adicionar novo token
    echo "GITHUB_RUNNER_TOKEN=$NEW_TOKEN" >> "$ENV_FILE"
fi

echo "✅ Token atualizado!"
echo ""
echo "🔄 Reinicie o cluster:"
echo "docker-compose down && docker-compose up -d"
echo ""
echo "📊 Verifique os logs:"
echo "docker-compose logs github-runner"