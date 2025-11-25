#!/bin/bash
set -e

# Script de entrada para o GitHub Actions Runner
echo "🚀 Iniciando GitHub Actions Runner..."

# Verificar se as variáveis necessárias estão definidas
if [ -z "$RUNNER_TOKEN" ]; then
    echo "❌ ERRO: GITHUB_RUNNER_TOKEN não definido"
    exit 1
fi

if [ -z "$REPO_URL" ]; then
    echo "❌ ERRO: REPO_URL não definido"
    exit 1
fi

# Garantir que estamos no diretório do runner (WORKDIR na imagem é /home/runner/actions-runner)
cd /home/runner/actions-runner || true

# Se o runner já está configurado, não tente reconfigurar (evita erros que fazem o container sair)
if [ -f ".runner" ] || [ -d ".credentials" ]; then
    echo "⚠️  Runner já configurado — pulando etapa de configuração." 
else
    echo "⚙️  Configurando runner diretamente com PAT..."
    # Tentar configurar; se a configuração falhar por já estar configurado, botão --replace lida com isso.
    # Mantemos comportamento seguro: se o comando falhar por outro motivo, logamos e continuamos (não faremos o container reiniciar automaticamente).
    if ! ./config.sh \
        --unattended \
        --url "$REPO_URL" \
        --pat "$RUNNER_TOKEN" \
        --name "${RUNNER_NAME:-dolorestec-runner}" \
        --work "${RUNNER_WORKDIR:-_work}" \
        --replace; then
        echo "⚠️  Aviso: falha ao configurar o runner. Tentando remover configuração pré-existente e reconfigurar..."
        ./config.sh remove || true
        ./config.sh \
            --unattended \
            --url "$REPO_URL" \
            --pat "$RUNNER_TOKEN" \
            --name "${RUNNER_NAME:-dolorestec-runner}" \
            --work "${RUNNER_WORKDIR:-_work}" \
            --replace || true
    fi
fi

# Executar o runner (usar exec para repassar sinais corretamente)
echo "▶️  Iniciando runner..."
exec ./run.sh