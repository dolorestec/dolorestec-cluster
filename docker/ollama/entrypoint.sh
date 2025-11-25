#!/bin/bash
set -e

echo "🚀 Iniciando Ollama Server..."

# Iniciar o servidor em background
ollama serve &

# Aguardar o servidor ficar pronto
echo "⏳ Aguardando Ollama ficar pronto..."
until ollama list > /dev/null 2>&1; do
    sleep 2
done

echo "✅ Ollama pronto. Verificando modelos..."

# Verificar se os modelos já existem
MODELS=$(ollama list | awk 'NR>1 {print $1}')

# Criar modelos se não existirem
if ! echo "$MODELS" | grep -q "dolores"; then
    echo "📦 Criando modelo Dolores..."
    ollama create dolores -f /opt/modelfiles/Dolores/Modelfile
fi

if ! echo "$MODELS" | grep -q "paulo"; then
    echo "📦 Criando modelo Paulo..."
    ollama create paulo -f /opt/modelfiles/Paulo/Modelfile
fi

if ! echo "$MODELS" | grep -q "sofia"; then
    echo "📦 Criando modelo Sofia..."
    ollama create sofia -f /opt/modelfiles/Sofia/Modelfile
fi

echo "🎉 Todos os modelos estão prontos!"
echo "📋 Modelos disponíveis:"
ollama list

# Manter o servidor rodando
wait